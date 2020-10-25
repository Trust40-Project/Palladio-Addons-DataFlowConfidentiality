package org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.impl

import java.util.Collection
import java.util.Stack
import org.apache.log4j.Logger
import org.eclipse.emf.ecore.EObject
import org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.ConfidentialityVariableCharacterisation
import org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.behaviour.DataChannelBehaviour
import org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.characteristics.Characteristic
import org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.characteristics.EnumCharacteristic
import org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.expression.AbstractNamedReferenceReference
import org.palladiosimulator.dataflow.confidentiality.pcm.model.profile.ProfileConstants.CharacterisableStereotype
import org.palladiosimulator.dataflow.confidentiality.pcm.model.profile.ProfileConstants.DataChannelBehaviorStereotype
import org.palladiosimulator.dataflow.confidentiality.pcm.queryutilsorg.palladiosimulator.dataflow.confidentiality.pcm.queryutils.ModelQueryUtils
import org.palladiosimulator.dataflow.confidentiality.pcm.queryutilsorg.palladiosimulator.dataflow.confidentiality.pcm.queryutils.PcmQueryUtils
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.PcmToDfdTransformation
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.impl.devided.DataFlowTransformation
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.impl.devided.TermTransformation
import org.palladiosimulator.dataflow.diagram.DataFlowDiagram.ExternalActor
import org.palladiosimulator.dataflow.diagram.characterized.DataFlowDiagramCharacterized.CharacterizedActorProcess
import org.palladiosimulator.dataflow.diagram.characterized.DataFlowDiagramCharacterized.CharacterizedProcess
import org.palladiosimulator.indirections.actions.ConsumeDataAction
import org.palladiosimulator.indirections.actions.EmitDataAction
import org.palladiosimulator.indirections.repository.DataChannel
import org.palladiosimulator.mdsdprofiles.api.StereotypeAPI
import org.palladiosimulator.pcm.core.composition.AssemblyContext
import org.palladiosimulator.pcm.core.entity.ComposedProvidingRequiringEntity
import org.palladiosimulator.pcm.parameter.VariableUsage
import org.palladiosimulator.pcm.repository.BasicComponent
import org.palladiosimulator.pcm.repository.OperationSignature
import org.palladiosimulator.pcm.seff.AbstractAction
import org.palladiosimulator.pcm.seff.ExternalCallAction
import org.palladiosimulator.pcm.seff.ResourceDemandingSEFF
import org.palladiosimulator.pcm.seff.ServiceEffectSpecification
import org.palladiosimulator.pcm.seff.SetVariableAction
import org.palladiosimulator.pcm.system.System
import org.palladiosimulator.pcm.usagemodel.EntryLevelSystemCall
import org.palladiosimulator.pcm.usagemodel.ScenarioBehaviour
import org.palladiosimulator.pcm.usagemodel.UsageModel

import static org.apache.commons.lang3.Validate.*
import static org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.impl.devided.TransformationConstants.EMPTY_STACK
import static org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.impl.devided.TransformationConstants.RESULT_PIN_NAME
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.impl.devided.DFDEntityCreator
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.impl.devided.DDEntityCreator
import org.palladiosimulator.pcm.usagemodel.UsageScenario

class PcmToDfdTransformationImplementation implements PcmToDfdTransformation {

	static val LOGGER = Logger.getLogger(PcmToDfdTransformationImplementation)
	val extension ModelQueryUtils queryUtils = new ModelQueryUtils
	val extension PcmQueryUtils pcmQueryUtils = new PcmQueryUtils
	val extension DFDFactoryUtilities dfdFactoryUtils = new DFDFactoryUtilities
	val dfd = createDataFlowDiagram
	val dd = createDataDictionary
	val extension DFDEntityCreator entityCreator
	val extension TermTransformation termTransformation
	val extension DDEntityCreator characteristicTransformation
	val extension DataFlowTransformation dataFlowTransformation

	new() {
		entityCreator = new DFDEntityCreator(dfd)
		characteristicTransformation = new DDEntityCreator(dd)
		termTransformation = new TermTransformation(characteristicTransformation, entityCreator)
		dataFlowTransformation = new DataFlowTransformation(entityCreator)
	}

	override transform(Collection<UsageModel> usageModels) {
		// transform all scenario behaviours, i.e. the user behaviour
		var scenarioBehaviours = usageModels.flatMap[usageScenario_UsageModel].map[scenarioBehaviour_UsageScenario]
		for (scenarioBehaviour : scenarioBehaviours) {
			LOGGER.info("Transforming " + ScenarioBehaviour.simpleName + " " + scenarioBehaviour.entityName)
			transform(scenarioBehaviour)
		}

		// transform the system (identify by following all entry level system calls)
		val assemblyContexts = scenarioBehaviours.flatMap[findAllChildrenIncludingSelfOfType(EntryLevelSystemCall)].map [
			providedRole_EntryLevelSystemCall.providingEntity_ProvidedRole
		].filter(System).toSet.sortBy[id].flatMap[assemblyContexts__ComposedStructure]
		assemblyContexts.forEach[ac|ac.transform(EMPTY_STACK)]

		// return transformation result
		new TransformationResultImpl(dfd, dd, null)
	}
	
	

	// ==================== System ====================
	
	protected def void transform(AssemblyContext ac, Stack<AssemblyContext> context) {
		isTrue(context.isEmpty() || context.peek !== ac)
		val component = ac.encapsulatedComponent__AssemblyContext
		component.transformComponent(context.newStack(ac))
	}



	// ==================== RD-SEFF ====================
	
	protected def dispatch transformComponent(BasicComponent bc, Stack<AssemblyContext> context) {
		isTrue(context.peek.encapsulatedComponent__AssemblyContext === bc)
		bc.serviceEffectSpecifications__BasicComponent.forEach[transformSEFF(context)]
	}
	
	protected def dispatch transformSEFF(ResourceDemandingSEFF seff, Stack<AssemblyContext> context) {
		isInstanceOf(OperationSignature, seff.describedService__SEFF)
		val operationSignature = seff.describedService__SEFF as OperationSignature
		
		//TODO clarify if data sinks can also be inputs for the SEFF entry process
		val requiresEntryProcess = !operationSignature.parameters__OperationSignature.isEmpty
		if (requiresEntryProcess) {
			seff.transformToEntryProcess(context)
		}
		
		val requiresExitProcess = operationSignature.returnType__OperationSignature !== null
		if (requiresExitProcess) {
			seff.transformToExitProcess(context)
		}
		
		seff.findAllChildrenIncludingSelfOfType(AbstractAction).forEach[action | action.transformAction(context)]
	}
	
	
	protected def transformToEntryProcess(ServiceEffectSpecification seff, Stack<AssemblyContext> context) {
		isInstanceOf(OperationSignature, seff.describedService__SEFF)
		val signature = seff.describedService__SEFF as OperationSignature
		notNull(signature.parameters__OperationSignature)
		isTrue(signature.parameters__OperationSignature.size > 0)
		
		val process = getEntryProcess(seff, context)
		val parameterNames = signature.parameters__OperationSignature.map[parameterName]

		for (parameter : parameterNames) {
			val inputPin = process.getInputPin(parameter)
			val outputPin = process.getOutputPin(parameter)
			process.createCopyAssignment(outputPin, inputPin)
		}
		
		// the callers have to create the incoming data flows
		// the users of parameters have to create outgoing data flows

		process
	}
	
	protected def transformToExitProcess(ResourceDemandingSEFF seff, Stack<AssemblyContext> context) {
		isInstanceOf(OperationSignature, seff.describedService__SEFF)
		notNull((seff.describedService__SEFF as OperationSignature).returnType__OperationSignature)
		val process = getExitProcess(seff, context)
		val inputPin = process.getInputPin(RESULT_PIN_NAME)
		val outputPin = process.getOutputPin(RESULT_PIN_NAME)
		process.createCopyAssignment(outputPin, inputPin)
		
		process.createDataFlowsToSeffExitProcess(seff, context)
		
		process
	}
	
	protected def dispatch transformSEFF(ServiceEffectSpecification seff, Stack<AssemblyContext> context) {
		// only in preparation for future new SEFF types
		throw new UnsupportedOperationException("No handler has been defined for SEFF type " + seff.class.simpleName)
	}
	
	protected def dispatch transformAction(ExternalCallAction action, Stack<AssemblyContext> context) {
		val requiresEntryProcess = !action.calledService_ExternalService.parameters__OperationSignature.isEmpty
		if (requiresEntryProcess) {
			action.transformToEntryProcess(context)
		}
		
		val requiresExitProcess = action.calledService_ExternalService.returnType__OperationSignature !== null
		if (requiresExitProcess) {
			action.transformToExitProcess(context)
		}
	}
	
	protected def dispatch transformAction(EmitDataAction action, Stack<AssemblyContext> context) {
		val process = action.getProcess(context)
		val inputPin = process.getInputPin(action.variableReference.referenceName)
		val outputPin = process.getOutputPin(action.dataSourceRole)
		process.createCopyAssignment(outputPin, inputPin)
		process.createOutgoingDataFlows(action.dataSourceRole, context)
		process.createDataFlows(action.variableReference, context)
		process
	}
	
	protected def dispatch transformAction(ConsumeDataAction action, Stack<AssemblyContext> context) {
		val process = action.getProcess(context)
		val inputPin = process.getInputPin(action.dataSinkRole)
		val outputPin = process.getOutputPin(action.variableReference.referenceName)
		process.createCopyAssignment(outputPin, inputPin)
		// emit actions and data channels already provide data flows to these actions
		process
	}
	
	protected def dispatch transformAction(SetVariableAction action, Stack<AssemblyContext> context) {
		val process = action.getProcess(context)
		process.addPinsAndBehavior(action.localVariableUsages_SetVariableAction, context, true)
		process
	}
	
	protected def dispatch transformAction(AbstractAction action, Stack<AssemblyContext> context) {
		// action not relevant, discarding
	}
	
	protected def transformToEntryProcess(ExternalCallAction eca, Stack<AssemblyContext> context) {
		val process = eca.getEntryProcess(context)
		process.addPinsAndBehavior(eca.inputVariableUsages__CallAction, context, true)
		process
	}
	
	protected def transformToExitProcess(ExternalCallAction eca, Stack<AssemblyContext> context) {
		val process = eca.getExitProcess(context)
		process.addPinsAndBehavior(eca.returnVariableUsage__CallReturnAction, context, true)
		process
	}
	
	
	
	// ==================== Data Channel ====================
	
	protected def dispatch transformComponent(DataChannel dc, Stack<AssemblyContext> context) {
		val process = dc.getProcess(context)
		
		// create pins
		dc.dataSinkRoles.forEach[role | process.getInputPin(role)]
		dc.dataSourceRoles.forEach[role | process.getOutputPin(role)]
		
		// create behaviour		
		val behaviour = dc.confidentialityBehavior.orElseThrow
		process.addPinsAndBehavior(behaviour.variableUsages, context, false)
		
		// create data flows
		dc.dataSourceRoles.forEach[role | process.createOutgoingDataFlows(role, context)]
		
		process
	}
	
	protected def dispatch transformComponent(ComposedProvidingRequiringEntity cc, Stack<AssemblyContext> context) {
		isTrue(context.peek.encapsulatedComponent__AssemblyContext === cc)
		cc.assemblyContexts__ComposedStructure.forEach[transform(context)]
	}


	
	// ==================== User Behaviour ====================

	protected def transform(ScenarioBehaviour scenarioBehaviour) {
		val elscs = scenarioBehaviour.findAllChildrenIncludingSelfOfType(EntryLevelSystemCall)
		for (elsc : elscs) {
			transform(elsc)
		}
	}
	
	protected def transform(EntryLevelSystemCall elsc) {
		val correspondingActor = elsc.correspondingActorName.actor
		
		val requiresEntryProcess = !elsc.operationSignature__EntryLevelSystemCall.parameters__OperationSignature.isEmpty
		if (requiresEntryProcess) {
			elsc.transformToEntryProcess(correspondingActor)
		}
		
		val requiresExitProcess = elsc.operationSignature__EntryLevelSystemCall.returnType__OperationSignature !== null
		if (requiresExitProcess) {
			elsc.transformToExitProcess(correspondingActor)
		}
	}
	
	protected def transformToEntryProcess(EntryLevelSystemCall elsc, ExternalActor actor) {
		val process = elsc.getEntryProcess(actor)
		process.addPinsAndBehavior(elsc.inputParameterUsages_EntryLevelSystemCall)
		process.createDataFlows(elsc.inputParameterUsages_EntryLevelSystemCall, EMPTY_STACK)
		
		val calledSeff = elsc.providedRole_EntryLevelSystemCall.findCalledSeff(elsc.operationSignature__EntryLevelSystemCall, EMPTY_STACK)
		val dstProcess = calledSeff.seff.getEntryProcess(calledSeff.context)
		val targetParameters = elsc.operationSignature__EntryLevelSystemCall.parameters__OperationSignature.map[parameterName]
		for (targetParameter : targetParameters) {
			val dstPin = dstProcess.getInputPin(targetParameter)
			val srcPin = process.getOutputPin(targetParameter)
			getDataFlow(process, srcPin, dstProcess, dstPin)
		}
		
		process
	}
	
	protected def transformToExitProcess(EntryLevelSystemCall elsc, ExternalActor actor) {
		val process = elsc.getExitProcess(actor)
		process.addPinsAndBehavior(elsc.outputParameterUsages_EntryLevelSystemCall)
		process.createDataFlows(elsc.outputParameterUsages_EntryLevelSystemCall, EMPTY_STACK)
		process
	}
	
	protected def addPinsAndBehavior(CharacterizedActorProcess process, Iterable<VariableUsage> variableUsages) {
		process.addPinsAndBehavior(variableUsages, EMPTY_STACK, true)
	}
	
	
	
	// ==================== Behaviour / Data Flow Helpers ====================

	protected def addPinsAndBehavior(CharacterizedProcess process, Iterable<VariableUsage> variableUsages, Stack<AssemblyContext> context, boolean createDataFlows) {
		// create input pins
		val requiredVariableNames = variableUsages.flatMap [
			findAllChildrenIncludingSelfOfType(AbstractNamedReferenceReference)
		].map[namedReference.referenceName].toSet.sort
		requiredVariableNames.forEach[name|process.getInputPin(name)]

		// create output pins
		for (variableUsage : variableUsages) {
			val variableName = variableUsage.namedReference__VariableUsage.referenceName
			val outputPin = process.getOutputPin(variableName);

			// create behaviour
			val confidentialityCharacterisations = variableUsage.variableCharacterisation_VariableUsage.filter(
				ConfidentialityVariableCharacterisation)
			for (characterisation : confidentialityCharacterisations) {
				val lhs = characterisation.lhs.transformLhsTerm(outputPin)
				val rhs = characterisation.rhs.transformRhsTerm(process, context)
				createAssignment(process, lhs, rhs)
			}
		}
		
		if (createDataFlows) {
			process.createDataFlows(variableUsages, context)			
		}

		process
	}

	protected def <T> newStack(Stack<T> stack, T newTop) {
		val newStack = new Stack()
		newStack.addAll(stack)
		newStack.push(newTop)
		newStack
	}
	
	
	
	/* =========== Query Utils =========== */
	
	protected def getCorrespondingActorName(EObject eobject) {
		val usageScenario = eobject.findParentOfType(UsageScenario, true)
		if (usageScenario === null) {
			return null
		}
		eobject.characteristics.correspondingActorName ?: usageScenario.characteristics.correspondingActorName ?:
			'''Actor_«usageScenario.entityName»_«usageScenario.id»'''
	}
	
	protected def getCorrespondingActorName(Collection<Characteristic<?>> characteristics) {
		characteristics.filter(EnumCharacteristic).filter [
			type.name == "CorrespondingActor"
		].flatMap[values].map[name].findFirst[true]
	}
	
	

	/* =========== Profiles Handling =========== */
	
	protected def getCharacteristics(EObject eobject) {
		StereotypeAPI.<Collection<Characteristic<?>>>getTaggedValueSafe(eobject, CharacterisableStereotype.VALUE_NAME,
			CharacterisableStereotype.NAME).orElse(#[])
	}
	
	protected def getConfidentialityBehavior(DataChannel dc) {
		StereotypeAPI.<DataChannelBehaviour>getTaggedValueSafe(dc, DataChannelBehaviorStereotype.VALUE_NAME,
			DataChannelBehaviorStereotype.NAME)
	}

}

package org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.impl

import java.util.ArrayList
import java.util.Collection
import java.util.HashSet
import java.util.LinkedList
import java.util.List
import java.util.Map
import org.eclipse.emf.ecore.util.EcoreUtil
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.Assignment
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.CharacterizableAssemblyContext
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.CharacterizableScenarioBehavior
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.CharacterizedEntryLevelSystemCall
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.CharacterizedExternalCallAction
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.CharacterizedResourceDemandingSEFF
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.characteristics.Characteristic
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.expressions.ParameterCharacteristicReference
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.expressions.ReturnCharacteristicReference
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.expressions.SeffParameterCharacteristicReference
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.expressions.SeffReturnCharacteristicReference
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.repository.DBOperationInterface
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.PcmToDfdTransformation
import org.palladiosimulator.dataflow.diagram.characterized.DataFlowDiagramCharacterized.Characterizable
import org.palladiosimulator.dataflow.diagram.characterized.DataFlowDiagramCharacterized.CharacterizedExternalActor
import org.palladiosimulator.dataflow.diagram.characterized.DataFlowDiagramCharacterized.CharacterizedProcess
import org.palladiosimulator.dataflow.diagram.characterized.DataFlowDiagramCharacterized.CharacterizedStore
import org.palladiosimulator.dataflow.dictionary.characterized.DataDictionaryCharacterized.CharacteristicType
import org.palladiosimulator.dataflow.dictionary.characterized.DataDictionaryCharacterized.Pin
import org.palladiosimulator.dataflow.dictionary.characterized.DataDictionaryCharacterized.expressions.BinaryLogicTerm
import org.palladiosimulator.dataflow.dictionary.characterized.DataDictionaryCharacterized.expressions.Constant
import org.palladiosimulator.dataflow.dictionary.characterized.DataDictionaryCharacterized.expressions.ContainerCharacteristicReference
import org.palladiosimulator.dataflow.dictionary.characterized.DataDictionaryCharacterized.expressions.DataCharacteristicReference
import org.palladiosimulator.dataflow.dictionary.characterized.DataDictionaryCharacterized.expressions.UnaryLogicTerm
import org.palladiosimulator.pcm.core.composition.AssemblyContext
import org.palladiosimulator.pcm.repository.OperationSignature
import org.palladiosimulator.pcm.repository.Parameter
import org.palladiosimulator.pcm.repository.RepositoryComponent
import org.palladiosimulator.pcm.seff.AbstractAction
import org.palladiosimulator.pcm.seff.ResourceDemandingSEFF
import org.palladiosimulator.pcm.usagemodel.EntryLevelSystemCall
import org.palladiosimulator.pcm.usagemodel.ScenarioBehaviour
import org.palladiosimulator.pcm.usagemodel.UsageModel

class PcmToDfdTransformationImpl implements PcmToDfdTransformation {
	
	extension DFDFactoryUtilities dfdFactoryUtilities = new DFDFactoryUtilities
	extension ModelQueryUtils modelQueryUtils = new ModelQueryUtils
	extension PcmQueryUtils pcmQueryUtils = new PcmQueryUtils
	extension DataFlowAdder dataFlowConsumer = null;
	extension NodeAdder nodeAdder = null;
	extension TraceRecorder traceRecorder = null;
	
	override transform(UsageModel usageModel) {
		val trace = new TransformationTraceImpl
		val dfd = createDataFlowDiagram
		dataFlowConsumer = [flow | dfd.edges.add(flow)]
		nodeAdder = [node | dfd.nodes.add(node)]
		traceRecorder = [ srcId, dstId | trace.addToTrace(srcId, dstId)]
		usageModel.transformAllBehaviors
		new TransformationResultImpl(dfd, trace)
	}
	
	protected def void transformAllBehaviors(UsageModel usageModel) {
		val processedSeffs = new HashSet<CharacterizedSeffWithContext>
		val behaviors = usageModel.usageScenario_UsageModel.map[scenarioBehaviour_UsageScenario]
		for (behavior : behaviors) {
			behavior.transformBehavior(processedSeffs)
		}
	}
	
	protected def void transformBehavior(ScenarioBehaviour behavior, Collection<CharacterizedSeffWithContext> processedSeffs) {
		val actor = behavior.getActor
		actor.addToDiagram
		
		val elscs = behavior.actions_ScenarioBehaviour.filter(CharacterizedEntryLevelSystemCall)
		for (elsc : elscs) {
			elsc.transformEntryLevelSystemCall(actor, processedSeffs)
		}
	}
	
	protected def void transformEntryLevelSystemCall(CharacterizedEntryLevelSystemCall elsc, CharacterizedExternalActor actor, Collection<CharacterizedSeffWithContext> processedSeffs) {
		addToDiagram(elsc.getEntryProcess(actor))
		addToDiagram(elsc.getExitProcess(actor))
		
		val seffQueue = new LinkedList<CharacterizedSeffWithContext>
		seffQueue += elsc.providedRole_EntryLevelSystemCall.findCalledCharacterizedSeff(elsc.operationSignature__EntryLevelSystemCall, #[])
		while (!seffQueue.isEmpty) {
			val seffWithContext = seffQueue.pop
			if (!processedSeffs.contains(seffWithContext)) {
				processedSeffs += seffWithContext
				seffQueue += seffWithContext.transformSeff
			}
		}
	}
	
	protected def transformSeff(CharacterizedSeffWithContext seffWithContext) {		
		addToDiagram(seffWithContext.entryProcess)
		addToDiagram(seffWithContext.exitProcess)
		
		val discoveredSeffs = new ArrayList
		val context = seffWithContext.context
		val seff = seffWithContext.seff
		val ecas = seff.findChildrenOfType(CharacterizedExternalCallAction)
		for (eca : ecas) {
			addToDiagram(eca.getEntryProcess(context))
			addToDiagram(eca.getExitProcess(context))
			val calledSignature = eca.calledService_ExternalService
			val calledRole = eca.role_ExternalService
			val calledSeff = calledRole.findCalledCharacterizedSeff(calledSignature, context)
			discoveredSeffs += calledSeff
		}
		
		discoveredSeffs
	}
	
	protected def create actor: createActor getActor(ScenarioBehaviour behavior) {
		addToTrace(behavior, actor)
		actor.name = behavior.entityName
		actor.createBehavior
	}
	
	protected def getEntryProcess(CharacterizedEntryLevelSystemCall elsc, CharacterizedExternalActor actor) {
		val process = elsc.entryProcess
		if (process !== null) {
			process.actor = actor
		}
		process
	}
	
	protected def getEntryProcess(CharacterizedEntryLevelSystemCall elsc) {
		if (elsc.operationSignature__EntryLevelSystemCall.parameters__OperationSignature.isEmpty) {
			return null
		}
		elsc.entryProcessPreconditionChecked
	}
	
	/**
	 * Creates the entry actor process.
	 * The following entities are created:<ul>
	 * <li>input pins (based on calls referred to from assignments)</li>
	 * <li>data flows to input pins</li>
	 * <li>output pins (based on parameters of called service)</li>
	 * <li>data flows to service</li>
	 * <li>assignments to outgoing flows to service</li>
	 * </ul>
	 */
	private def create process: createActorProcess getEntryProcessPreconditionChecked(CharacterizedEntryLevelSystemCall elsc) {
		addToTrace(elsc, process)
		process.name = '''«elsc.entityName» EntryProcess'''
		process.createCharacteristics(elsc.scenarioBehaviour_AbstractUserAction)
		process.createBehavior
		for (requiredElsc : elsc.findRequiriedEntryLevelSystemCalls) {
			val inputPin = process.getInputPin(requiredElsc)
			val requiredProcess = requiredElsc.exitProcess
			val requiredPin = requiredProcess.outputPin
			createDataFlow(requiredProcess, requiredPin, process, inputPin).addToDiagram
		}
		val role = elsc.providedRole_EntryLevelSystemCall
		val signature = elsc.operationSignature__EntryLevelSystemCall
		val calledSeff = role.findCalledSeff(signature, #[])
		val seffEntryProcess = calledSeff.seff.getEntryProcess(calledSeff.context)
		for (parameter : signature.parameters__OperationSignature) {
			val outputPin = process.getOutputPin(parameter)
			val seffEntryPin = seffEntryProcess.getInputPin(parameter)
			createDataFlow(process, outputPin, seffEntryProcess, seffEntryPin).addToDiagram
		}
		for (assignment : elsc.parameterAssignments) {
			val newLhs = process._translate(null, assignment.lhs)
			val newRhs = process.translate(null, assignment.rhs)
			process.createAssignment(newLhs, newRhs)		
		}
	}
	
	/**
	 * Used by EntryLevelSystemCall to specify dependency to result of other call.
	 */
	protected def create pin: createPin getInputPin(CharacterizedProcess process, EntryLevelSystemCall referencedCall) {
		pin.name = '''«process.name» in for «referencedCall.entityName»'''
		process.behavior.inputs += pin
	}
	
	/**
	 * Used by EntryLevelSystemCall to specify provided characteristics for a parameter of a call
	 * Used by ResourceDemandingSEFF to specify provided characteristics for a SEFF parameter provided to contained calls
	 */
	protected def create pin: createPin getOutputPin(CharacterizedProcess process, Parameter parameter) {
		pin.name = '''«process.name» out for «parameter.parameterName»'''
		process.behavior.outputs += pin
	}
	
	protected def getExitProcess(CharacterizedEntryLevelSystemCall elsc, CharacterizedExternalActor actor) {
		val process = elsc.exitProcess
		if (process !== null) {
			process.actor = actor			
		}
		process
	}
	
	protected def getExitProcess(CharacterizedEntryLevelSystemCall elsc) {
		if (elsc.operationSignature__EntryLevelSystemCall.returnType__OperationSignature === null) {
			return null
		}
		elsc.exitProcessPreconditionChecked
	}
	
	/**
	 * Creates the exit actor process.
	 * The following entities are created:<ul>
	 * <li>one output pin (provide return value from service call to others)</li>
	 * <li>one input pin (return value from service call)</li>
	 * <li>copy assignment from input to output</li>
	 * <li>data flow from service to this process</li>
	 * </ul>
	 */
	private def create process: createActorProcess getExitProcessPreconditionChecked(CharacterizedEntryLevelSystemCall elsc) {
		addToTrace(elsc, process)
		process.name = '''«elsc.entityName» ExitProcess'''
		process.createCharacteristics(elsc.scenarioBehaviour_AbstractUserAction)
		process.createBehavior
		val outputPin = process.getOutputPin
		val inputPin = process.getInputPin
		process.createCopyAssignment(outputPin, inputPin)
		val calledSeff = elsc.providedRole_EntryLevelSystemCall.findCalledCharacterizedSeff(elsc.operationSignature__EntryLevelSystemCall, #[])
		val seffProcess = calledSeff.characterizedSeff.getExitProcess(calledSeff.context)
		val seffPin = seffProcess.outputPin
		createDataFlow(seffProcess, seffPin, process, inputPin).addToDiagram
	}
	
	/**
	 * Used by all processes that only have one input pin by definition.
	 */
	protected def create pin: createPin getInputPin(CharacterizedProcess process) {
		pin.name = '''«process.name» in for result'''
		process.behavior.inputs += pin
	}
	
	/**
	 * Used by all processes that only have one output pin by definition.
	 */
	protected def create pin: createPin getOutputPin(CharacterizedProcess process) {
		pin.name = '''«process.name» out for result'''
		process.behavior.outputs += pin
	}
	
	protected def CharacterizedProcess getEntryProcess(CharacterizedSeffWithContext seffWithContext) {
		seffWithContext.seff.getEntryProcess(seffWithContext.context)
	}
	
	protected def CharacterizedProcess getEntryProcess(ResourceDemandingSEFF seff, List<AssemblyContext> context) {
		val signature = seff.describedService__SEFF
		if (!(signature instanceof OperationSignature)) {
			return null
		}
		val parameters = (signature as OperationSignature).parameters__OperationSignature
		if (parameters.isEmpty) {
			return null
		}
		
		val dbProcess = seff.describedService__SEFF.eContainer instanceof DBOperationInterface
		seff.getEntryProcessPreconditionChecked(context, dbProcess)
	}
	
	/**
	 * Creates the entry process for SEFFs.
	 * The following entities are created:<ul>
	 * <li>input pin for every parameter</li>
	 * <li>output pin for every parameter</li>
	 * <li>copy assignment from input to output</li>
	 * </ul>
	 */
	protected def create process: createProcess getEntryProcessPreconditionChecked(ResourceDemandingSEFF seff, List<AssemblyContext> context, boolean dbProcess) {
		addToTrace(seff, process)
		process.name = '''SEFF «seff.basicComponent_ServiceEffectSpecification.entityName»::«seff.describedService__SEFF.entityName» EntryProcess'''
		process.createCharacteristics(context)
		process.createBehavior
		val signature = seff.describedService__SEFF as OperationSignature
		for (parameter : signature.parameters__OperationSignature) {
			val inputPin = process.getInputPin(parameter)
			val outputPin = process.getOutputPin(parameter)
			createCopyAssignment(process, outputPin, inputPin)

			if (dbProcess) {
				val dbInterface = seff.describedService__SEFF.eContainer as DBOperationInterface
				val store = dbInterface.getStore(context)
				val storeInputPin = store.inputPin
				createDataFlow(process, outputPin, store, storeInputPin).addToDiagram
			}

		}

	}
	
	protected def create store: createStore getStore(DBOperationInterface dbInterface, List<AssemblyContext> context) {
		addToTrace(dbInterface, store)
		store.name = '''Store «dbInterface.entityName»'''
		store.createCharacteristics(context)
		store.createBehavior
		store.inputPin
		store.outputPin
		store.addToDiagram //TODO quite uncommon to do this here
	}
	
	protected def create pin: createPin getInputPin(CharacterizedStore store) {
		pin.name = "in"
		store.behavior.inputs += pin
	}
	
	protected def create pin: createPin getOutputPin(CharacterizedStore store) {
		pin.name = "out"
		store.behavior.outputs += pin
	}
		
	/**
	 * Used by ResourceDemandingSEFF to specify required characteristics for a parameter of a call
	 */
	protected def create pin: createPin getInputPin(CharacterizedProcess process, Parameter parameter) {
		pin.name = '''«process.name» input for «parameter.parameterName»'''
		process.behavior.inputs += pin
	}
	
	protected def getExitProcess(CharacterizedSeffWithContext seffWithContext) {
		seffWithContext.characterizedSeff.getExitProcess(seffWithContext.context)
	}
	
	protected def getExitProcess(CharacterizedResourceDemandingSEFF seff, List<AssemblyContext> context) {
		if (!(seff.describedService__SEFF instanceof OperationSignature)) {
			return null
		}
		val signature = seff.describedService__SEFF as OperationSignature
		if (signature.returnType__OperationSignature === null) {
			return null
		}
		
		val dbProcess = seff.describedService__SEFF.eContainer instanceof DBOperationInterface
		seff.getExitProcessPreconditionChecked(context, dbProcess)
	}
	
	/**
	 * Creates the exit process for SEFFs.
	 * The following entities are created:<ul>
	 * <li>input pin for every external service call that has a return value</li>
	 * <li>data flow from every external service call to the input pin</li>
	 * <li>one output pin</li>
	 * <li>assignments to output pin based on given seff return assignments</li>
	 * </ul>
	 */
	protected def create process: createProcess getExitProcessPreconditionChecked(CharacterizedResourceDemandingSEFF seff, List<AssemblyContext> context, boolean dbProcess) {
		addToTrace(seff, process)
		process.name = '''SEFF «seff.basicComponent_ServiceEffectSpecification.entityName»::«seff.describedService__SEFF.entityName» ExitProcess'''
		process.createCharacteristics(context)
		process.createBehavior
		
		val availableActions = seff.findChildrenOfType(CharacterizedExternalCallAction).filter[calledService_ExternalService.returnType__OperationSignature !== null]
		for (availableAction : availableActions) {
			val inputPin = process.getInputPin(availableAction)
			val calledProcess = availableAction.getExitProcess(context)
			val calledPin = calledProcess.outputPin
			createDataFlow(calledProcess, calledPin, process, inputPin).addToDiagram
		}
		val outputPin = process.outputPin
		
		if (dbProcess) {
			val dbInterface = seff.describedService__SEFF.eContainer as DBOperationInterface
			val store = dbInterface.getStore(context)
			val storeOutputPin = store.outputPin
			val processInputPin = process.inputPin
			createDataFlow(store, storeOutputPin, process, processInputPin).addToDiagram			
			process.createCopyAssignment(outputPin, processInputPin)
		}
		
		for (returnAssignment : seff.returnAssignments) {
			val lhs = process._translate(context, returnAssignment.lhs)
			val rhs = process.translate(context, returnAssignment.rhs)
			process.createAssignment(lhs, rhs)
		}
	}
	
    /**
	 * Used by ResourceDemandingSEFF to dependency to a contained action.
	 */
	protected def create pin: createPin getInputPin(CharacterizedProcess process, AbstractAction action) {
		pin.name = '''«process.name» in for «action.entityName»'''
		process.behavior.inputs += pin
	}
	
	protected def getEntryProcess(CharacterizedExternalCallAction eca, List<AssemblyContext> context) {
		if (eca.calledService_ExternalService.parameters__OperationSignature.isEmpty) {
			return null
		}
		eca.getEntryProcessPreconditionChecked(context)
	}
	
	/**
	 * Create an input pin for every referred SEFF parameter or call return value
	 * Create an output pin for every parameter of the called signature
	 */
	 
	/**
	 * Creates the entry process for an external service call.
	 * The following entities are created:<ul>
	 * <li>input pin for every required parameter of the containing signature (SEFF)</li>
	 * <li>data flows from SEFF entry process to input pin of the created process for every required parameter</li>
	 * <li>input pin for every required result of another external call</li>
	 * <li>data flow from required call to the created process</li>
	 * <li>output pin for every parameter of the called service</li>
	 * <li>output data flow to every parameter pin of called service (SEFF)</li>
	 * <li>assignments for every output pin based on defined assignments</li>
	 * </ul>
	 */
	protected def create process: createProcess getEntryProcessPreconditionChecked(CharacterizedExternalCallAction eca, List<AssemblyContext> context) {
		addToTrace(eca, process)
		process.name = '''ECA «eca.findParentOfType(RepositoryComponent).entityName»::«eca.entityName» EntryProcess'''
		process.createCharacteristics(context)
		process.createBehavior
		
		val seff = eca.findParentOfType(CharacterizedResourceDemandingSEFF)
		val seffProcess = seff.getEntryProcess(context)
		val paramAssignments = eca.parameterAssignments
		val seffParameters = paramAssignments.flatMap[findAllChildrenIncludingSelfOfType(SeffParameterCharacteristicReference)].map[parameter].toSet.sortBy[parameterName]
		for (seffParameter : seffParameters) {
			val inputPin = process.getInputPin(seffParameter)
			val requiredPin = seffProcess.getOutputPin(seffParameter)
			createDataFlow(seffProcess, requiredPin, process, inputPin).addToDiagram
		}
		val requiredCalls = paramAssignments.flatMap[findAllChildrenIncludingSelfOfType(ReturnCharacteristicReference)].map[externalCallAction].filter(CharacterizedExternalCallAction).toSet.sortBy[id]
		for (requiredCall : requiredCalls) {
			val inputPin = process.getInputPin(requiredCall)
			val requiredProcess = requiredCall.getExitProcess(context)
			val requiredPin = requiredProcess.outputPin
			createDataFlow(requiredProcess, requiredPin, process, inputPin).addToDiagram
		}
		
		val calledSeff = eca.role_ExternalService.findCalledCharacterizedSeff(eca.calledService_ExternalService, context)
		val calledProcess = calledSeff.entryProcess
		for (parameter : eca.calledService_ExternalService.parameters__OperationSignature) {
			val outputPin = process.getOutputPin(parameter)
			val calledInputPin = calledProcess.getInputPin(parameter)
			createDataFlow(process, outputPin, calledProcess, calledInputPin).addToDiagram
		}
		
		for (paramAssignment : paramAssignments) {
			val lhs = process._translate(context, paramAssignment.lhs)
			val rhs = process.translate(context, paramAssignment.rhs)
			process.createAssignment(lhs, rhs)
		}
	}

	protected def getExitProcess(CharacterizedExternalCallAction eca, List<AssemblyContext> context) {
		if (eca.calledService_ExternalService.returnType__OperationSignature === null) {
			return null
		}
		eca.getExitProcessPreconditionChecked(context)
	}

	/**
	 * Creates the exit process for an external service call.
	 * The following entities are created:<ul>
	 * <li>one input pin for the call result</li>
	 * <li>one output pin for providing the call results to others</li>
	 * <li>copy assignment from input to output</li>
	 * <li>data flow from exit process of called service to the created process</li>
	 * </ul>
	 */
	private def create process: createProcess getExitProcessPreconditionChecked(CharacterizedExternalCallAction eca, List<AssemblyContext> context) {
		addToTrace(eca, process)
		process.name = '''ECA «eca.entityName» ExitProcess'''
		process.createCharacteristics(context)
		process.createBehavior
		
		val inputPin = process.inputPin
		val outputPin = process.outputPin
		process.createCopyAssignment(outputPin, inputPin)
		
		val calledSeff = eca.role_ExternalService.findCalledCharacterizedSeff(eca.calledService_ExternalService, context)
		val calledProcess = calledSeff.exitProcess
		val calledOutputPin = calledProcess.outputPin
		
		createDataFlow(calledProcess, calledOutputPin, process, inputPin).addToDiagram
	}

	protected def createCharacteristics(Characterizable characterizable, ScenarioBehaviour behavior) {
		if (behavior instanceof CharacterizableScenarioBehavior) {
			val foundCharacteristics = behavior.characteristics.groupBy[type]
			characterizable.createCharacteristics(foundCharacteristics)
		}
	}

	protected def createCharacteristics(Characterizable characterizable, List<AssemblyContext> context) {
		val foundCharacteristics = context.findCharacteristics.groupBy[type]
		characterizable.createCharacteristics(foundCharacteristics)
	}
	
	protected def createCharacteristics(Characterizable characterizable, Map<CharacteristicType, List<Characteristic>> characteristics) {
		for (foundCharacteristic : characteristics.entrySet) {
			val values = foundCharacteristic.value.map[value]
			characterizable.characteristics += foundCharacteristic.key.createCharacteristic(values)
		}
	}
	
	protected def findCharacteristics(List<AssemblyContext> context) {
		for (assemblyContext : context.reverseView.filter(CharacterizableAssemblyContext)) {
			if (!assemblyContext.characteristics.isEmpty) {
				return assemblyContext.characteristics
			}
		}
		#[]
	}

	protected def dispatch DataCharacteristicReference translate(CharacterizedProcess behaving, List<AssemblyContext> contexts, SeffReturnCharacteristicReference term) {
		// only on lhs of assignment
		val outputPin = behaving.getOutputPin()
		createDataCharacteristicReference(outputPin, term.characteristicType, term.literal)
	}
	
	protected def dispatch DataCharacteristicReference translate(CharacterizedProcess behaving, List<AssemblyContext> contexts, SeffParameterCharacteristicReference term) {
		// only on rhs of assignment
		val inputPin = behaving.getInputPin(term.parameter)
		createDataCharacteristicReference(inputPin, term.characteristicType, term.literal)
	}
	
	protected def dispatch DataCharacteristicReference translate(CharacterizedProcess behaving, List<AssemblyContext> contexts, ReturnCharacteristicReference term) {
		// can occur on lhs and rhs
		
		// lhs case
		val assignment = term.findParentOfType(Assignment)
		if (assignment?.lhs == term) {
			// behaving is an exit process, therefore it only has one output pin
			val outputPin = behaving.outputPin
			return createDataCharacteristicReference(outputPin, term.characteristicType, term.literal)
		}
		
		// rhs case
		var Pin inputPin = null;
		if (term.entryLevelSystemCall !== null) {
			inputPin = behaving.getInputPin(term.entryLevelSystemCall)
		} else if (term.externalCallAction !== null) {
			inputPin = behaving.getInputPin(term.externalCallAction)
		} else {
			throw new IllegalArgumentException("There is no call contained")
		}
		createDataCharacteristicReference(inputPin, term.characteristicType, term.literal)
	}
	
	protected def dispatch DataCharacteristicReference translate(CharacterizedProcess behaving, List<AssemblyContext> contexts, ParameterCharacteristicReference term) {
		// only occurs on lhs of assignment
		val outputPin = behaving.getOutputPin(term.parameter)
		createDataCharacteristicReference(outputPin, term.characteristicType, term.literal)
	}
	
	protected def dispatch ContainerCharacteristicReference translate(CharacterizedProcess behaving, List<AssemblyContext> contexts, ContainerCharacteristicReference term) {
		createContainerCharacteristicReference(term.characteristicType, term.literal)
	}
	
	protected def dispatch BinaryLogicTerm translate(CharacterizedProcess behaving, List<AssemblyContext> contexts, BinaryLogicTerm term) {
		val copy = EcoreUtil.copy(term)
		copy.left = behaving.translate(contexts, term.left)
		copy.right = behaving.translate(contexts, term.right)
		copy
	}
	
	protected def dispatch UnaryLogicTerm translate(CharacterizedProcess behaving, List<AssemblyContext> contexts, UnaryLogicTerm term) {
		val copy = EcoreUtil.copy(term)
		copy.term = behaving.translate(contexts, term.term)
		copy
	}
	
	protected def dispatch Constant translate(CharacterizedProcess behaving, List<AssemblyContext> contexts, Constant term) {
		EcoreUtil.copy(term)
	}

}
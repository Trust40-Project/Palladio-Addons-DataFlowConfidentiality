package org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.impl.devided

import de.uka.ipd.sdq.stoex.AbstractNamedReference
import de.uka.ipd.sdq.stoex.StoexFactory
import de.uka.ipd.sdq.stoex.VariableReference
import java.util.HashMap
import java.util.Stack
import org.palladiosimulator.dataflow.confidentiality.pcm.queryutils.DataActionWithContext
import org.palladiosimulator.dataflow.confidentiality.pcm.queryutils.DataSinkRoleWithContext
import org.palladiosimulator.dataflow.confidentiality.pcm.queryutils.ModelQueryUtils
import org.palladiosimulator.dataflow.confidentiality.pcm.queryutils.PcmQueryUtils
import org.palladiosimulator.dataflow.confidentiality.pcm.queryutils.SeffWithContext
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.impl.queries.NamedReferenceTargetFinder
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.impl.queries.NamedReferenceTargetFinder.DataSinkRoleReferenceTarget
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.impl.queries.NamedReferenceTargetFinder.ParameterVariableReferenceTarget
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.impl.queries.NamedReferenceTargetFinder.SEFFActionVariableReferenceTarget
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.impl.queries.NamedReferenceTargetFinder.SEFFReferenceTarget
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.impl.queries.NamedReferenceTargetFinder.UserActionVariableReferenceTarget
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.impl.queries.NamedReferenceTargetFinder.VariableReferenceTarget
import org.palladiosimulator.dataflow.diagram.DataFlowDiagram.Node
import org.palladiosimulator.dataflow.diagram.characterized.DataFlowDiagramCharacterized.CharacterizedProcess
import org.palladiosimulator.dataflow.dictionary.characterized.DataDictionaryCharacterized.Pin
import org.palladiosimulator.indirections.repository.DataChannel
import org.palladiosimulator.indirections.repository.DataSourceRole
import org.palladiosimulator.pcm.core.composition.AssemblyContext
import org.palladiosimulator.pcm.parameter.VariableUsage
import org.palladiosimulator.pcm.repository.BasicComponent
import org.palladiosimulator.pcm.repository.OperationRequiredRole
import org.palladiosimulator.pcm.repository.OperationSignature
import org.palladiosimulator.pcm.seff.ExternalCallAction
import org.palladiosimulator.pcm.seff.ResourceDemandingSEFF
import org.palladiosimulator.pcm.usagemodel.EntryLevelSystemCall

import static org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.impl.devided.TransformationConstants.*

class DataFlowTransformation {
	
	val extension ModelQueryUtils queryUtils = new ModelQueryUtils
	val extension PcmQueryUtils pcmQueryUtils = new PcmQueryUtils
	val extension NamedReferenceTargetFinder referenceFinder = new NamedReferenceTargetFinder
	val extension TransformationResultGetter resultGetter
	
	new(TransformationResultGetter resultGetter) {
		this.resultGetter = resultGetter
	}
	
	def createDataFlowsToSeffExitProcess(CharacterizedProcess process, ResourceDemandingSEFF seff, Stack<AssemblyContext> context) {
		val lastAction = seff.stopAction
		val dstProcess = seff.getExitProcess(context)
		val dstPin = dstProcess.getInputPin(RESULT_PIN_NAME)

		val virtualReference = StoexFactory.eINSTANCE.createVariableReference
		virtualReference.referenceName = RESULT_PIN_NAME
		val srcPins = virtualReference.findTarget(lastAction, context).map[getPinInternal(context)]

		srcPins.createDataFlows(process, dstPin)
	}
	
	def createOutgoingDataFlows(CharacterizedProcess process, OperationSignature operationSignature, OperationRequiredRole requiredRole, Stack<AssemblyContext> context) {
		val destinationSeff = requiredRole.findCalledSeff(operationSignature, context)
		val destinationProcess = getEntryProcess(destinationSeff.seff, destinationSeff.context)
		for (parameter : operationSignature.parameters__OperationSignature.map[parameterName]) {
			val outputPin = process.getOutputPin(parameter)
			val inputPin = destinationProcess.getInputPin(parameter)
			getDataFlow(process, outputPin, destinationProcess, inputPin)
		}
	}
	
	def createOutgoingDataFlows(CharacterizedProcess process, DataSourceRole dataSourceRole, Stack<AssemblyContext> context) {
		val outputPin = process.getOutputPin(dataSourceRole)
		val destinations = dataSourceRole.findDestinations(context)
		for (destination : destinations) {
			if (destination instanceof DataActionWithContext) {
				val action = destination.dataAction
				val actionContext = destination.context
				val dstProcess = action.getProcess(actionContext)
				val dstPin = dstProcess.getInputPin(destination.dataSinkRole)
				getDataFlow(process, outputPin, dstProcess, dstPin)
			} else if (destination instanceof DataSinkRoleWithContext) {
				val dataChannel = destination.dataChannel
				val dataChannelContext = destination.context
				val dataChannelRole = destination.dataSinkRole
				val dstProcess = dataChannel.getProcess(dataChannelContext)
				val dstPin = dstProcess.getInputPin(dataChannelRole)
				getDataFlow(process, outputPin, dstProcess, dstPin)
			} else {
				// error!
				println("ERROR: no handler for destination type.")
			}
		}
	}
	
	def createDataFlows(CharacterizedProcess process, Iterable<VariableUsage> variableUsages,
		Stack<AssemblyContext> context) {
		val dataSources = process.collectDataSources(variableUsages, context)
		for (dataSource : dataSources.entrySet.sortBy[key.name]) {
			val dstPin = dataSource.key
			val srcPins = dataSource.value
			srcPins.createDataFlows(process, dstPin)
		}
	}
	
	def createDataFlows(CharacterizedProcess process, VariableReference reference,
		Stack<AssemblyContext> context) {
		val dataSources = new HashMap
		val inputPin = process.getInputPin(reference.referenceName)
		dataSources.computeIfAbsent(inputPin, [reference.getPins(context)])
		for (dataSource : dataSources.entrySet) {
			val dstPin = dataSource.key
			val srcPins = dataSource.value
			srcPins.createDataFlows(process, dstPin)
		}
	}
	
	protected def createDataFlows(Iterable<Pin> srcPins, CharacterizedProcess dstProcess, Pin dstPin) {
			if (srcPins.isEmpty) {
				// that must not happen
				println("Attention!")
			}
			for (srcPin : srcPins) {
				val srcNode = srcPin.owner.findParentOfType(Node, false)
				resultGetter.getDataFlow(srcNode, srcPin, dstProcess, dstPin)
			}
	}
	

	
	protected def collectDataSources(CharacterizedProcess process, Iterable<VariableUsage> variableUsages,
		Stack<AssemblyContext> contexts) {
		val pins = new HashMap
		val references = variableUsages.flatMap[referencedVariables]
		for (reference : references) {
			val inputPin = process.getInputPin(reference.referenceName)
			pins.computeIfAbsent(inputPin, [reference.getPins(contexts)])
		}
		pins
	}

	protected def getReferencedVariables(VariableUsage variableUsage) {
		variableUsage.variableCharacterisation_VariableUsage.flatMap [
			findAllChildrenIncludingSelfOfType(AbstractNamedReference)
		]
	}
		
	/*
	 * ==================================================
	 * Helpers to get pins that named references refer to
	 * ==================================================
	 */
	
	protected def getPins(AbstractNamedReference reference, Stack<AssemblyContext> context) {
		reference.findTarget(context).map[getPinInternal(context)]
	}
	
	protected def dispatch getPinInternal(VariableReferenceTarget target, Stack<AssemblyContext> contexts) {
		throw new UnsupportedOperationException("No handler for given type " + target.class + " available.")
	}
	
	protected def dispatch getPinInternal(DataSinkRoleReferenceTarget target, Stack<AssemblyContext> contexts) {
		var component = target.getTarget.providingEntity_ProvidedRole
		if (component instanceof DataChannel) {
			val process = component.getProcess(contexts)
			return process.getInputPin(target.getReferenceName)
		} else {
			throw new IllegalArgumentException
		}
	}
	
	protected def dispatch getPinInternal(ParameterVariableReferenceTarget target, Stack<AssemblyContext> contexts) {
		val ac = contexts.peek
		val parameter = target.getTarget
		val operationSignature = parameter.operationSignature__Parameter
		val component = ac.encapsulatedComponent__AssemblyContext as BasicComponent
		val seff = component.serviceEffectSpecifications__BasicComponent.filter(ResourceDemandingSEFF).findFirst [
			describedService__SEFF === operationSignature
		]
		val process = seff.getEntryProcess(contexts)
		return process.getOutputPin(target.getReferenceName)
	}
	
	protected def dispatch getPinInternal(SEFFReferenceTarget target, Stack<AssemblyContext> context) {
		// we have to be in the context of a call action
		var calledSeff = null as SeffWithContext
		if (context.isEmpty) {
			val elsc = target.reference.findParentOfType(EntryLevelSystemCall, false)
			calledSeff = elsc.providedRole_EntryLevelSystemCall.findCalledSeff(
				elsc.operationSignature__EntryLevelSystemCall, context)
		} else {
			val eca = target.reference.findParentOfType(ExternalCallAction, false)
			calledSeff = eca.role_ExternalService.findCalledSeff(eca.calledService_ExternalService, context)
		}
		val process = calledSeff.seff.getExitProcess(calledSeff.context)
		val pin = process.getOutputPin(RESULT_PIN_NAME)
		return pin
	}
	
	protected def dispatch getPinInternal(SEFFActionVariableReferenceTarget target, Stack<AssemblyContext> contexts) {
		val seffAction = target.getTarget
		var process = null as CharacterizedProcess
		if (seffAction instanceof ExternalCallAction) {
			process = seffAction.getExitProcess(contexts)
		} else {
			process = seffAction.getProcess(contexts)
		}
		return process.getOutputPin(target.getReferenceName)
	}
	
	protected def dispatch getPinInternal(UserActionVariableReferenceTarget target, Stack<AssemblyContext> contexts) {
		val userAction = target.getTarget
		val process = userAction.getExitProcess
		return process.getOutputPin(target.getReferenceName)
	}
	
}
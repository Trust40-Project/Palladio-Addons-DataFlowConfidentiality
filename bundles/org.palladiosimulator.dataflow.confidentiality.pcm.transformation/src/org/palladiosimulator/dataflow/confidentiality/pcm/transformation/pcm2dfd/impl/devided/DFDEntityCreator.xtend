package org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.impl.devided

import java.util.Stack
import org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.behaviour.DataChannelBehaviour
import org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.repository.OperationalDataStoreComponent
import org.palladiosimulator.dataflow.confidentiality.pcm.model.profile.ProfileConstants
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.impl.DFDFactoryUtilities
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.trace.impl.TransformationTraceModifier
import org.palladiosimulator.dataflow.diagram.DataFlowDiagram.DataFlowDiagram
import org.palladiosimulator.dataflow.diagram.DataFlowDiagram.ExternalActor
import org.palladiosimulator.dataflow.diagram.DataFlowDiagram.Node
import org.palladiosimulator.dataflow.diagram.characterized.DataFlowDiagramCharacterized.CharacterizedNode
import org.palladiosimulator.dataflow.diagram.characterized.DataFlowDiagramCharacterized.CharacterizedStore
import org.palladiosimulator.dataflow.dictionary.characterized.DataDictionaryCharacterized.Pin
import org.palladiosimulator.indirections.repository.DataChannel
import org.palladiosimulator.indirections.repository.DataSinkRole
import org.palladiosimulator.indirections.repository.DataSourceRole
import org.palladiosimulator.mdsdprofiles.api.StereotypeAPI
import org.palladiosimulator.pcm.core.composition.AssemblyContext
import org.palladiosimulator.pcm.seff.AbstractAction
import org.palladiosimulator.pcm.seff.ServiceEffectSpecification
import org.palladiosimulator.pcm.usagemodel.AbstractUserAction

class DFDEntityCreator implements TransformationResultGetter {
	
	val extension DFDFactoryUtilities dfdFactoryUtils = new DFDFactoryUtilities
	val extension TransformationTraceModifier traceRecorder
	val DataFlowDiagram dfd
	
	
	new(DataFlowDiagram dfd, TransformationTraceModifier traceRecorder) {
		this.dfd = dfd
		this.traceRecorder = traceRecorder
	}
	
	def create actor: createActor getActor(String actorName) {
//		addTraceEntry(behavior, actor)
		actor.name = actorName
		actor.createBehavior
		dfd.nodes += actor
	}
	
	def getExitProcess(AbstractUserAction action, ExternalActor actor) {
		val process = action.getExitProcess()
		process.actor = actor
		process
	}
	
	override create process : createActorProcess getExitProcess(AbstractUserAction action) {
		// requirement: at some point in time, the exit process creation method that takes an actor has to be called
		process.name = '''UserAction Exit «action.entityName»'''
		process.createBehavior
		dfd.nodes += process
		addTraceEntry(action, process)
	}
	
	def getEntryProcess(AbstractUserAction action, ExternalActor actor) {
		val process = action.getEntryProcess
		process.actor = actor
		process
	}
	
	override create process : createActorProcess getEntryProcess(AbstractUserAction action) {
		process.name = '''UserAction Entry «action.entityName»'''
		process.createBehavior
		dfd.nodes += process
		addTraceEntry(action, process)
	}
	
	override create process : createProcess getExitProcess(AbstractAction action, Stack<AssemblyContext> context) {
		process.name = '''Action Exit «action.entityName»'''
		process.createBehavior
		dfd.nodes += process
		addTraceEntry(action, context, process)
	}
	
	override create process : createProcess getEntryProcess(AbstractAction action, Stack<AssemblyContext> context) {
		process.name = '''Action Entry «action.entityName»'''
		process.createBehavior
		dfd.nodes += process
		addTraceEntry(action, context, process)
	}
	
	override create process : createProcess getProcess(AbstractAction action, Stack<AssemblyContext> context) {
		process.name = '''Action «action.entityName»'''
		process.createBehavior
		dfd.nodes += process
		addTraceEntry(action, context, process)
	}
	
	override create process : createProcess getExitProcess(ServiceEffectSpecification seff, Stack<AssemblyContext> context) {
		process.name = '''SEFF Exit «context.peek.entityName».«seff.describedService__SEFF.entityName»'''
		process.createBehavior
		dfd.nodes += process
		addTraceEntry(seff, context, process)
	}
	
	override create process : createProcess getEntryProcess(ServiceEffectSpecification seff, Stack<AssemblyContext> context) {
		
		process.name = '''SEFF Entry «context.peek.entityName».«seff.describedService__SEFF.entityName»'''
		process.createBehavior
		dfd.nodes += process
		addTraceEntry(seff, context, process)
	}
	
	override getProcess(DataChannel dc, Stack<AssemblyContext> context) {
		if (isStoreDataChannel(dc)) {
			dc.getStore(context)
		} else {
			dc.getCharacterizedProcess(context)
		}
	}
	
	protected def create process : createProcess getCharacterizedProcess(DataChannel dc, Stack<AssemblyContext> context) {
		process.name = '''DC «context.peek.entityName».«dc.entityName»'''
		process.createBehavior
		dfd.nodes += process
		addTraceEntry(dc, context, process)
	}
	
	override create store : createStore getStore(OperationalDataStoreComponent component, Stack<AssemblyContext> context) {
		store.name = '''Store «context.peek.entityName».«component.entityName»'''
		store.createBehavior
		dfd.nodes += store
		addTraceEntry(component, context, store)
	}
	
	override create store : createStore getStore(DataChannel dc, Stack<AssemblyContext> context) {
		store.name = '''Store «context.peek.entityName».«dc.entityName»'''
		store.createBehavior
		dfd.nodes += store
		addTraceEntry(dc, context, store)
	}
	
	override create pin: createPin getOutputPin(CharacterizedNode process, String pinName) {
		pin.name = pinName
		process.behavior.outputs += pin
	}
	
	override create pin: createPin getInputPin(CharacterizedNode process, String pinName) {
		pin.name = pinName
		process.behavior.inputs += pin
	}
	
	override getOutputPin(CharacterizedNode process, DataSourceRole role) {
		val roleName = role.entityName
		val parameterName = role.dataInterface.dataSignature.parameter.parameterName
		val pinName = '''«roleName».«parameterName»''' 
		process.getOutputPin(pinName);
	}
	
	override getInputPin(CharacterizedNode process, DataSinkRole role) {
		val pinName = '''«role.entityName».«role.dataInterface.dataSignature.parameter.parameterName»'''
		process.getInputPin(pinName);
	}
	
	override create pin: createPin getOutputPin(CharacterizedStore store) {
		pin.name = TransformationConstants.STORE_OUTPUT_PIN_NAME
		store.behavior.outputs += pin
	}
	
	override create pin: createPin getInputPin(CharacterizedStore store) {
		pin.name = TransformationConstants.STORE_INPUT_PIN_NAME
		store.behavior.inputs += pin
	}
	
	override create flow : createDataFlow getDataFlow(CharacterizedNode source, Pin sourcePin, CharacterizedNode destination, Pin destinationPin) {
		//TODO calculate and set name
		flow.name = "data"
		flow.source = source as Node
		flow.sourcePin = sourcePin
		flow.target = destination as Node
		flow.targetPin = destinationPin
		dfd.edges += flow
	}
	

	protected def isStoreDataChannel(DataChannel dc) {
		val behavior = dc.confidentialityBehavior
		if (!behavior.isPresent) {
			return false
		}
		behavior.get.reusedBehaviours.map[reusedBehaviour].exists[entityName == TransformationConstants.STORE_BEHAVIOUR_NAME]
	}
	
	def getConfidentialityBehavior(DataChannel dc) {
		StereotypeAPI.<DataChannelBehaviour>getTaggedValueSafe(dc, ProfileConstants.dataChannelBehavior.value,
			ProfileConstants.dataChannelBehavior.stereotype)
	}
}
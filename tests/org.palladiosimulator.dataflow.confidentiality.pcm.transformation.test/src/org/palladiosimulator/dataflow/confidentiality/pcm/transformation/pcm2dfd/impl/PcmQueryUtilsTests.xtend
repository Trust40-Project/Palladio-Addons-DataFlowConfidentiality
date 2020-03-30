package org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.impl

import java.util.ArrayList
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.junit.jupiter.api.BeforeAll
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.test.util.StandaloneInitializer
import org.palladiosimulator.pcm.core.composition.AssemblyContext
import org.palladiosimulator.pcm.core.composition.ComposedStructure
import org.palladiosimulator.pcm.repository.BasicComponent
import org.palladiosimulator.pcm.seff.ExternalCallAction
import org.palladiosimulator.pcm.seff.ResourceDemandingSEFF
import org.palladiosimulator.pcm.system.System
import org.palladiosimulator.pcm.usagemodel.EntryLevelSystemCall
import org.palladiosimulator.pcm.usagemodel.UsageModel

import static org.junit.jupiter.api.Assertions.*
import static org.palladiosimulator.dataflow.confidentiality.pcm.transformation.test.util.URIHelper.*

class PcmQueryUtilsTests {
	
	var PcmQueryUtils subject
	var Iterable<EntryLevelSystemCall> elscs
	var ResourceDemandingSEFF implementingSeff
	var ResourceDemandingSEFF delegatingSeff
	var System pcmSystem
	
	@BeforeAll
	static def void init() {
		StandaloneInitializer.init
	}
	
	@BeforeEach
	def void setup() {
		subject = new PcmQueryUtils
		val rs = new ResourceSetImpl
		val usageModel = rs.getResource(getModelURI("SeffFinding/newUsageModel.usagemodel"), true).contents.head as UsageModel
		elscs = usageModel.usageScenario_UsageModel.head.scenarioBehaviour_UsageScenario.actions_ScenarioBehaviour.filter(EntryLevelSystemCall)
		pcmSystem = elscs.head.providedRole_EntryLevelSystemCall.providingEntity_ProvidedRole as System
		val repository = elscs.head.operationSignature__EntryLevelSystemCall.interface__OperationSignature.repository__Interface
		val basicComponents = repository.components__Repository.filter(BasicComponent)
		implementingSeff = basicComponents.findFirst[entityName == "ImplementingComponent0"].serviceEffectSpecifications__BasicComponent.findFirst[describedService__SEFF.entityName == "get"] as ResourceDemandingSEFF
		delegatingSeff = basicComponents.findFirst[entityName == "DelegatingComponent2"].serviceEffectSpecifications__BasicComponent.findFirst[describedService__SEFF.entityName == "get"] as ResourceDemandingSEFF
	}
	
	@Test
	def void testSeffFindingEntryLevelSystemCallDirectImplementingComponent() {
		val expectedContext = pcmSystem.getAssemblyContextList("Assembly_ImplementingComponent0")
		val expected = new SeffWithContext(implementingSeff, expectedContext)
		val actual = "direct".findSeffFromElsc
		assertEquals(expected, actual)
	}
	
	@Test
	def void testSeffFindingEntryLevelSystemCallDirectDelegatingComponent() {
		val expectedContext = pcmSystem.getAssemblyContextList("Assembly_DelegatingComponent2")
		val expected = new SeffWithContext(delegatingSeff, expectedContext)
		val actual = "assemblyConnector".findSeffFromElsc
		assertEquals(expected, actual)
	}
	
	@Test
	def void testSeffFindingEntryLevelSystemCallCompositeDirectlyContainingImplementingComponent() {
		val expectedContext = pcmSystem.getAssemblyContextList("Assembly_CompositeComponent0", "Assembly_ImplementingComponent0")
		val expected = new SeffWithContext(implementingSeff, expectedContext)
		val actual = "compositeDirect".findSeffFromElsc
		assertEquals(expected, actual)
	}
	
	@Test
	def void testSeffFindingEntryLevelSystemCallCompositeNestedContainingImplementingComponent() {
		val expectedContext = pcmSystem.getAssemblyContextList("Assembly_CompositeComponent1", "Assembly_CompositeComponent0", "Assembly_ImplementingComponent0")
		val expected = new SeffWithContext(implementingSeff, expectedContext)
		val actual = "compositeNested".findSeffFromElsc
		assertEquals(expected, actual)
	}
	
	@Test
	def void testSeffFindingEntryLevelSystemCallCompositeDirectlyContainingDelegatingComponent() {
		val expectedContext = pcmSystem.getAssemblyContextList("Assembly_CompositeDelegating0", "Assembly_DelegatingComponent2")
		val expected = new SeffWithContext(delegatingSeff, expectedContext)
		val actual = "compositeDelegatingDirect".findSeffFromElsc
		assertEquals(expected, actual)
	}
	
	@Test
	def void testSeffFindingEntryLevelSystemCallCompositeNestedContainingDelegatingComponent() {
		val expectedContext = pcmSystem.getAssemblyContextList("Assembly_CompositeDelegating1", "Assembly_DelegatingComponent2")
		val expected = new SeffWithContext(delegatingSeff, expectedContext)
		val actual = "compositeDelegatingCompositeDirect".findSeffFromElsc
		assertEquals(expected, actual)
	}
	
	@Test
	def void testSeffFindingEntryLevelSystemCallCompositeCompositeDelegateNested() {
		val expectedContext = pcmSystem.getAssemblyContextList("Assembly_CompositeDelegateNested0", "Assembly_CompositeDelegating0", "Assembly_DelegatingComponent2")
		val expected = new SeffWithContext(delegatingSeff, expectedContext)
		val actual = "compositeDelegateNested".findSeffFromElsc
		assertEquals(expected, actual)
	}
	
	@Test
	def void testSeffFindingCallActionViaAssemblyConnector() {
		val eca = delegatingSeff.steps_Behaviour.filter(ExternalCallAction).findFirst[true]
		val signature = eca.calledService_ExternalService
		val requiredRole = eca.role_ExternalService
		val context = pcmSystem.getAssemblyContextList("Assembly_DelegatingComponent2")
		val expectedContext = pcmSystem.getAssemblyContextList("Assembly_ImplementingComponent0")
		val expected = new SeffWithContext(implementingSeff, expectedContext)
		val actual = subject.findCalledSeff(requiredRole, signature, context)
		assertEquals(expected, actual)		
	}
	
	@Test
	def void testSeffFindingCallActionViaRequiredDelegationConnector() {
		val eca = delegatingSeff.steps_Behaviour.filter(ExternalCallAction).findFirst[true]
		val signature = eca.calledService_ExternalService
		val requiredRole = eca.role_ExternalService
		val context = pcmSystem.getAssemblyContextList("Assembly_CompositeDelegating1", "Assembly_DelegatingComponent2")
		val expectedContext = pcmSystem.getAssemblyContextList("Assembly_CompositeComponent0", "Assembly_ImplementingComponent0")
		val expected = new SeffWithContext(implementingSeff, expectedContext)
		val actual = subject.findCalledSeff(requiredRole, signature, context)
		assertEquals(expected, actual)
	}
	
	@Test
	def void testSeffFindingCallActionViaRequiredDelegationConnectorInCompositeComponent() {
		val eca = delegatingSeff.steps_Behaviour.filter(ExternalCallAction).findFirst[true]
		val signature = eca.calledService_ExternalService
		val requiredRole = eca.role_ExternalService
		val context = pcmSystem.getAssemblyContextList("Assembly_CompositeDelegateNested0", "Assembly_CompositeDelegating0", "Assembly_DelegatingComponent2")
		val expectedContext = pcmSystem.getAssemblyContextList("Assembly_CompositeDelegateNested0", "Assembly_CompositeComponent0", "Assembly_ImplementingComponent0")
		val expected = new SeffWithContext(implementingSeff, expectedContext)
		val actual = subject.findCalledSeff(requiredRole, signature, context)
		assertEquals(expected, actual)
	}

	protected def findSeffFromElsc(String elscName) {
		val elsc = elscs.findFirst[entityName == elscName]
		val signature = elsc.operationSignature__EntryLevelSystemCall
		val role = elsc.providedRole_EntryLevelSystemCall
		subject.findCalledSeff(role, signature, #[])
	}
	
	protected def getAssemblyContextList(ComposedStructure cs, String... assemblyContextNames) {
		val foundAssemblyContexts = new ArrayList<AssemblyContext>
		var currentStructure = cs
		for (assemblyContextName : assemblyContextNames) {
			val assemblyContext = currentStructure.assemblyContexts__ComposedStructure.findFirst[entityName == assemblyContextName]
			foundAssemblyContexts += assemblyContext
			val component = assemblyContext.encapsulatedComponent__AssemblyContext
			if (component instanceof ComposedStructure) {
				currentStructure = component
			}
		}
		foundAssemblyContexts	
	}
	
}
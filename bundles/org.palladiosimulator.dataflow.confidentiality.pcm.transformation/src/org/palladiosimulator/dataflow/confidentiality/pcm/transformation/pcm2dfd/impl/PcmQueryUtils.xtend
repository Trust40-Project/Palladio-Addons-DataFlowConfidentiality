package org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.impl

import java.util.ArrayList
import java.util.HashSet
import java.util.List
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.CharacterizedEntryLevelSystemCall
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.CharacterizedResourceDemandingSEFF
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.expressions.ReturnCharacteristicReference
import org.palladiosimulator.pcm.core.composition.AssemblyConnector
import org.palladiosimulator.pcm.core.composition.AssemblyContext
import org.palladiosimulator.pcm.core.composition.ComposedStructure
import org.palladiosimulator.pcm.core.composition.ProvidedDelegationConnector
import org.palladiosimulator.pcm.core.composition.RequiredDelegationConnector
import org.palladiosimulator.pcm.repository.BasicComponent
import org.palladiosimulator.pcm.repository.ProvidedRole
import org.palladiosimulator.pcm.repository.RequiredRole
import org.palladiosimulator.pcm.repository.Signature
import org.palladiosimulator.pcm.seff.ResourceDemandingSEFF

class PcmQueryUtils {

	val extension ModelQueryUtils modelQueryUtils = new ModelQueryUtils

	/**
	 * Finds a called SEFF and the corresponding stack of assembly contexts.
	 * Always provides {@link CharacterizedResourceDemandingSEFF} elements.
	 * @see #findCalledSeff(ProvidedRole, Signature, List)
	 */
	def findCalledCharacterizedSeff(RequiredRole requiredRole, Signature calledSignature, List<AssemblyContext> contexts) {
		val foundSeff = requiredRole.findCalledSeff(calledSignature, contexts)
		new CharacterizedSeffWithContext(foundSeff.seff, foundSeff.context)
	}

	/**
	 * Finds a called SEFF and the corresponding stack of assembly contexts.
	 * It requires the context of the resolution process to be specified as stack of assembly contexts.
	 * The resulting stack can be completely different to the stack from which the call originated
	 * because composite components do not provide SEFFs but only contribute to the stack.
	 * 
	 * @param requiredRole The required role that points to the required component.
	 * @param calledSignature The signature that the SEFF describes.
	 * @param context The stack of assembly contexts that identifies the point from which
	 *        the call shall be resolved. The list starts with the most outer assembly context.
	 * @return A tuple of the resolved SEFF and the assembly context stack.
	 */
	def SeffWithContext findCalledSeff(RequiredRole requiredRole, Signature calledSignature, List<AssemblyContext> contexts) {
		val composedStructure = contexts.last.parentStructure__AssemblyContext
		val newcontext = new ArrayList(contexts)
		
		// test if there is an assembly connector satisfying the required role
		val assemblyConnector = composedStructure.connectors__ComposedStructure
			.filter(AssemblyConnector)
			.findFirst[
				requiredRole_AssemblyConnector === requiredRole &&
				requiringAssemblyContext_AssemblyConnector === newcontext.last
			]
		if (assemblyConnector !== null) {
			newcontext.remove(newcontext.last)
			val newAssemblyContext = assemblyConnector.providingAssemblyContext_AssemblyConnector
			val providedRole = assemblyConnector.providedRole_AssemblyConnector
			newcontext += newAssemblyContext
			return providedRole.findCalledSeff(calledSignature, newcontext)
		}
		
		// go to the parent composed structure to satisfy the required role
		val outerRequiredRole = composedStructure.connectors__ComposedStructure
			.filter(RequiredDelegationConnector)
			.filter[innerRequiredRole_RequiredDelegationConnector == requiredRole]
			.map[outerRequiredRole_RequiredDelegationConnector]
			.head
		newcontext.remove(newcontext.last)
		findCalledSeff(outerRequiredRole, calledSignature, newcontext)
	}

	/**
	 * Finds a called SEFF and the corresponding stack of assembly contexts.
	 * Always provides {@link CharacterizedResourceDemandingSEFF} elements.
	 * @see #findCalledSeff(RequiredRole, Signature, List)
	 */
	def findCalledCharacterizedSeff(ProvidedRole providedRole, Signature calledSignature, List<AssemblyContext> contexts) {
		val foundSeff = providedRole.findCalledSeff(calledSignature, contexts)
		new CharacterizedSeffWithContext(foundSeff.seff, foundSeff.context)
	}

	/**
	 * Finds a called SEFF and the corresponding stack of assembly contexts.
	 * It requires the context of the resolution process to be specified as stack of assembly contexts.
	 * The resulting stack can be completely different to the stack from which the call originated
	 * because composite components do not provide SEFFs but only contribute to the stack.
	 * 
	 * @param providedRole The provided role that points to the identifying component.
	 * @param calledSignature The signature that the SEFF describes.
	 * @param context The stack of assembly contexts that identifies the point from which
	 *        the call shall be resolved. The list starts with the most outer assembly context.
	 * @return A tuple of the resolved SEFF and the assembly context stack. 
	 */
	def findCalledSeff(ProvidedRole providedRole, Signature calledSignature, List<AssemblyContext> context) {
		val newContexts = new ArrayList(context)
		var role = providedRole
		var providingComponent = role.providingEntity_ProvidedRole
		while (providingComponent instanceof ComposedStructure) {
			val connector = providingComponent.findProvidedDelegationConnector(role)
			val assemblyContext = connector.assemblyContext_ProvidedDelegationConnector
			newContexts += assemblyContext
			role = connector.innerProvidedRole_ProvidedDelegationConnector
			providingComponent = role.providingEntity_ProvidedRole
		}
		if (providingComponent instanceof BasicComponent) {
			val seff = providingComponent.serviceEffectSpecifications__BasicComponent.filter(ResourceDemandingSEFF).
				findFirst[describedService__SEFF == calledSignature]
			return new SeffWithContext(seff, newContexts)
		}
	}
	
	private def findProvidedDelegationConnector(ComposedStructure component, ProvidedRole outerRole) {
		component.connectors__ComposedStructure.filter(ProvidedDelegationConnector).
				findFirst[outerProvidedRole_ProvidedDelegationConnector == outerRole]
	}

	def findRequiriedEntryLevelSystemCalls(CharacterizedEntryLevelSystemCall elsc) {
		val requiredElscs = new HashSet<CharacterizedEntryLevelSystemCall>
		for (assignment : elsc.parameterAssignments) {
			val elscs = assignment.rhs
				.findAllChildrenIncludingSelfOfType(ReturnCharacteristicReference)
				.map[entryLevelSystemCall]
				.filter(CharacterizedEntryLevelSystemCall)
			requiredElscs.addAll(elscs)
		}
		requiredElscs.sortBy[id]
	}

}

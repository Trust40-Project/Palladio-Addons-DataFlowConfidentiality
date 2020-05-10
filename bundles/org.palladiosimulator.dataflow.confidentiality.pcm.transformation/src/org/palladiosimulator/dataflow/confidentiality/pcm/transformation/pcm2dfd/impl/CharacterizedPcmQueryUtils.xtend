package org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.impl

import java.util.HashSet
import java.util.List
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.CharacterizedEntryLevelSystemCall
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.CharacterizedResourceDemandingSEFF
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.expressions.ReturnCharacteristicReference
import org.palladiosimulator.dataflow.confidentiality.pcm.queryutilsorg.palladiosimulator.dataflow.confidentiality.pcm.queryutils.ModelQueryUtils
import org.palladiosimulator.dataflow.confidentiality.pcm.queryutilsorg.palladiosimulator.dataflow.confidentiality.pcm.queryutils.PcmQueryUtils
import org.palladiosimulator.dataflow.confidentiality.pcm.queryutilsorg.palladiosimulator.dataflow.confidentiality.pcm.queryutils.SeffWithContext
import org.palladiosimulator.pcm.core.composition.AssemblyContext
import org.palladiosimulator.pcm.repository.ProvidedRole
import org.palladiosimulator.pcm.repository.RequiredRole
import org.palladiosimulator.pcm.repository.Role
import org.palladiosimulator.pcm.repository.Signature

class CharacterizedPcmQueryUtils extends PcmQueryUtils {

	val extension ModelQueryUtils modelQueryUtils = new ModelQueryUtils

	/**
	 * Finds a called SEFF and the corresponding stack of assembly contexts.
	 * Always provides {@link CharacterizedResourceDemandingSEFF} elements.
	 * @see #findCalledSeff(ProvidedRole, Signature, List)
	 */
	def findCalledCharacterizedSeff(RequiredRole requiredRole, Signature calledSignature,
		List<AssemblyContext> contexts) {
		requiredRole.findCalledSeff(calledSignature, contexts).convert
	}

	/**
	 * Finds a called SEFF and the corresponding stack of assembly contexts.
	 * Always provides {@link CharacterizedResourceDemandingSEFF} elements.
	 * @see #findCalledSeff(RequiredRole, Signature, List)
	 */
	def findCalledCharacterizedSeff(ProvidedRole providedRole, Signature calledSignature,
		List<AssemblyContext> contexts) {
		providedRole.findCalledSeff(calledSignature, contexts).convert
	}

	def findCalledCharacterizedSeffThrowing(RequiredRole requiredRole, Signature calledSignature,
		List<AssemblyContext> contexts) {
		requiredRole.findCalledCharacterizedSeff(calledSignature, contexts).throwIfNull(requiredRole, calledSignature,
			contexts)
	}

	def findCalledCharacterizedSeffThrowing(ProvidedRole providedRole, Signature calledSignature,
		List<AssemblyContext> contexts) {
		providedRole.findCalledCharacterizedSeff(calledSignature, contexts).throwIfNull(providedRole, calledSignature,
			contexts)
	}

	def findRequiriedEntryLevelSystemCalls(CharacterizedEntryLevelSystemCall elsc) {
		val requiredElscs = new HashSet<CharacterizedEntryLevelSystemCall>
		for (assignment : elsc.parameterAssignments) {
			val elscs = assignment.rhs.findAllChildrenIncludingSelfOfType(ReturnCharacteristicReference).map [
				entryLevelSystemCall
			].filter(CharacterizedEntryLevelSystemCall)
			requiredElscs.addAll(elscs)
		}
		requiredElscs.sortBy[id]
	}

	protected static def convert(SeffWithContext foundSeff) {
		if (foundSeff === null) {
			return null
		}
		new CharacterizedSeffWithContext(foundSeff.seff, foundSeff.context)
	}

	protected static def throwIfNull(CharacterizedSeffWithContext foundSeff, Role role, Signature calledSignature,
		List<AssemblyContext> contexts) {
		if (foundSeff === null) {
			val ac = contexts.last
			throw new IllegalArgumentException('''Could not find SEFF«IF ac !== null» for «ac.entityName» («ac.id»)«ENDIF» with role «role.entityName» and signature «calledSignature.entityName»''')
		}
		foundSeff
	}

}

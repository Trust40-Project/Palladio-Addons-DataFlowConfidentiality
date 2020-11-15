package org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.impl.queries

import de.uka.ipd.sdq.stoex.AbstractNamedReference
import java.util.ArrayList
import org.eclipse.emf.ecore.EObject
import org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.behaviour.DataChannelBehaviour
import org.palladiosimulator.dataflow.confidentiality.pcm.queryutilsorg.palladiosimulator.dataflow.confidentiality.pcm.queryutils.ModelQueryUtils
import org.palladiosimulator.dataflow.confidentiality.pcm.queryutilsorg.palladiosimulator.dataflow.confidentiality.pcm.queryutils.PcmQueryUtils
import org.palladiosimulator.indirections.actions.ConsumeDataAction
import org.palladiosimulator.indirections.repository.DataSinkRole
import org.palladiosimulator.pcm.parameter.VariableUsage
import org.palladiosimulator.pcm.repository.Parameter
import org.palladiosimulator.pcm.seff.AbstractAction
import org.palladiosimulator.pcm.seff.BranchAction
import org.palladiosimulator.pcm.seff.ExternalCallAction
import org.palladiosimulator.pcm.seff.ForkAction
import org.palladiosimulator.pcm.seff.LoopAction
import org.palladiosimulator.pcm.seff.ResourceDemandingBehaviour
import org.palladiosimulator.pcm.seff.ResourceDemandingSEFF
import org.palladiosimulator.pcm.seff.SetVariableAction
import org.palladiosimulator.pcm.seff.StopAction
import org.palladiosimulator.pcm.usagemodel.AbstractUserAction
import org.palladiosimulator.pcm.usagemodel.Branch
import org.palladiosimulator.pcm.usagemodel.EntryLevelSystemCall
import org.palladiosimulator.pcm.usagemodel.Loop
import org.palladiosimulator.pcm.usagemodel.ScenarioBehaviour
import org.palladiosimulator.pcm.usagemodel.Stop

import static org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.impl.devided.TransformationConstants.*
import org.palladiosimulator.pcm.seff.StartAction
import org.palladiosimulator.pcm.repository.OperationSignature
import org.palladiosimulator.indirections.actions.CreateDateAction

class NamedReferenceTargetFinder {
	
	val extension ModelQueryUtils queryUtils = new ModelQueryUtils
	val extension PcmQueryUtils pcmQueryUtils = new PcmQueryUtils

	/*
	 * ===============================================
	 * Helpers to identify targets of named references
	 * ===============================================
	 */
	
	def findTarget(AbstractNamedReference reference) {
		val containingUserAction = reference.findParentOfType(AbstractUserAction, false)
		if (containingUserAction !== null) {
			return reference.findTarget(containingUserAction)
		}
		
		val containingAction = reference.findParentOfType(AbstractAction, false)
		if (containingAction !== null) {
			return reference.findTarget(containingAction)
		}
		
		val dcBehaviour = reference.findParentOfType(DataChannelBehaviour, false)
		if (dcBehaviour !== null) {
			return reference.findTarget(dcBehaviour)
		}
		
		#[]
	}
	
	interface VariableReferenceTarget {
		
	}
	
	static abstract class SingleTargetVariableReferenceTarget<T extends EObject> implements VariableReferenceTarget {
		
		val AbstractNamedReference reference
		val T target
				
		new(AbstractNamedReference reference, T target) {
			this.reference = reference
			this.target = target
		}
		
		def getReference() {
			reference
		}
		
		def getReferenceName() {
			reference.referenceName
		}
		
		def T getTarget() {
			target
		}
	}
	
	/*
	 * ==================================================================
	 * Helpers to identify targets of named references in usage scenarios
	 * ==================================================================
	 */

	def Iterable<VariableReferenceTarget> findTarget(AbstractNamedReference reference, AbstractUserAction usingAction) {
		if (usingAction instanceof EntryLevelSystemCall && reference.referenceName == RESULT_PIN_NAME) {
			val call = (usingAction as EntryLevelSystemCall)
			val role = call.providedRole_EntryLevelSystemCall
			val signature = call.operationSignature__EntryLevelSystemCall
			val calledSeff = role.findCalledSeff(signature, EMPTY_STACK)
			return #[new SEFFReferenceTarget(reference, calledSeff.seff)]
		}
		for (var currentAction = usingAction; currentAction !== null; currentAction = currentAction.predecessor) {
			val result = reference.findTargetInternalUsage(currentAction)
			if (!result.isEmpty) {
				return result
			}
		}
		val parentAction = usingAction.findParentOfType(AbstractUserAction, false)
		if (parentAction !== null) {
			return reference.findTarget(parentAction)
		}
		#[]
	}
	
	protected def dispatch Iterable<VariableReferenceTarget> findTargetInternalUsage(AbstractNamedReference reference, AbstractUserAction currentAction) {
		#[]
	}
	
	protected def dispatch Iterable<VariableReferenceTarget> findTargetInternalUsage(AbstractNamedReference reference, Loop currentAction) {
		reference.findTargetInternal(currentAction.bodyBehaviour_Loop)
	}
	
	protected def dispatch Iterable<VariableReferenceTarget> findTargetInternalUsage(AbstractNamedReference reference, Branch currentAction) {
		currentAction.branchTransitions_Branch.flatMap[reference.findTargetInternal(branchedBehaviour_BranchTransition)]
	}
	
	protected def dispatch Iterable<VariableReferenceTarget> findTargetInternalUsage(AbstractNamedReference reference, EntryLevelSystemCall currentAction) {
		if (currentAction.outputParameterUsages_EntryLevelSystemCall.findVariableDefinition(reference) !== null) {
			#[new UserActionVariableReferenceTarget(reference, currentAction)]
		} else {
			#[]
		}
	}
	
	protected def findTargetInternal(AbstractNamedReference reference, ScenarioBehaviour behaviour) {
		reference.findTarget(behaviour.actions_ScenarioBehaviour.filter(Stop).findFirst[true])
	}
	
	static class UserActionVariableReferenceTarget extends SingleTargetVariableReferenceTarget<AbstractUserAction> {
		new(AbstractNamedReference reference, AbstractUserAction target) {
			super(reference, target)
		}
	}
	
	/*
	 * ===========================================================
	 * Helpers to identify targets of named references in RD-SEFFs
	 * ===========================================================
	 */
	
	def Iterable<VariableReferenceTarget> findTarget(AbstractNamedReference reference, AbstractAction usingAction) {
		for (var currentAction = usingAction; currentAction !== null; currentAction = currentAction.predecessor_AbstractAction) {
			val result = reference.findTargetInternalSeff(currentAction)
			if (!result.isEmpty) {
				return result
			}
		}
		val parentAction = usingAction.findParentOfType(AbstractAction, false)
		if (parentAction !== null) {
			return reference.findTarget(parentAction)
		}
		#[]
	}
	
	protected def dispatch Iterable<VariableReferenceTarget> findTargetInternalSeff(AbstractNamedReference reference, AbstractAction currentAction) {
		#[]
	}
	
	protected def dispatch Iterable<VariableReferenceTarget> findTargetInternalSeff(AbstractNamedReference reference, StartAction currentAction) {
		val parent = currentAction.findParentOfType(AbstractAction, false)
		if (parent !== null) {
			return #[]
		}
		// we are the top most start action, so try the fallback to parameters
		val rdseff = currentAction.findParentOfType(ResourceDemandingSEFF, false)
		val parameters = (rdseff.describedService__SEFF as OperationSignature).parameters__OperationSignature
		val matchingParameter = parameters.findFirst[reference.matchesName(parameterName)]
		if (matchingParameter === null) {
			return #[]
		}
		#[new ParameterVariableReferenceTarget(reference, matchingParameter)]
	}
	
	protected def dispatch Iterable<VariableReferenceTarget> findTargetInternalSeff(AbstractNamedReference reference,
		SetVariableAction currentAction) {
		if (currentAction.localVariableUsages_SetVariableAction.findVariableDefinition(reference) !== null) {
			return #[new SEFFActionVariableReferenceTarget(reference, currentAction)]
		}
		#[]
	}
	
	protected def dispatch Iterable<VariableReferenceTarget> findTargetInternalSeff(AbstractNamedReference reference,
		ExternalCallAction currentAction) {
		if (currentAction.returnVariableUsage__CallReturnAction.findVariableDefinition(reference) !== null) {
			return #[new SEFFActionVariableReferenceTarget(reference, currentAction)]
		}
		#[]
	}
	
	protected def dispatch Iterable<VariableReferenceTarget> findTargetInternalSeff(AbstractNamedReference reference,
		ConsumeDataAction currentAction) {
		if (currentAction.variableReference.matchesName(reference.referenceName)) {
			return #[new SEFFActionVariableReferenceTarget(reference, currentAction)]
		}
		#[]
	}
	
	protected def dispatch Iterable<VariableReferenceTarget> findTargetInternalSeff(AbstractNamedReference reference,
		CreateDateAction currentAction) {
		if (currentAction.variableReference.matchesName(reference.referenceName)) {
			return #[new SEFFActionVariableReferenceTarget(reference, currentAction)]
		}
		#[]
	}
	
	protected def dispatch Iterable<VariableReferenceTarget> findTargetInternalSeff(AbstractNamedReference reference,
		LoopAction currentAction) {
		reference.findTargetInternal(currentAction.bodyBehaviour_Loop)
	}

	protected def dispatch Iterable<VariableReferenceTarget> findTargetInternalSeff(AbstractNamedReference reference,
		BranchAction currentAction) {
		currentAction.branches_Branch.map[branchBehaviour_BranchTransition].flatMap [ behaviour |
			reference.findTargetInternal(behaviour)
		]
	}

	protected def dispatch Iterable<VariableReferenceTarget> findTargetInternalSeff(AbstractNamedReference reference,
		ForkAction currentAction) {
		currentAction.asynchronousForkedBehaviours_ForkAction.flatMap [ behaviour |
			reference.findTargetInternal(behaviour)
		]
	}

	protected def findTargetInternal(AbstractNamedReference reference, ResourceDemandingBehaviour behaviour) {
		reference.findTarget(behaviour.steps_Behaviour.filter(StopAction).findFirst[true])
	}
	
	static class SEFFReferenceTarget extends SingleTargetVariableReferenceTarget<ResourceDemandingSEFF> {
		new(AbstractNamedReference reference, ResourceDemandingSEFF target) {
			super(reference, target)
		}
	}
	
	static class SEFFActionVariableReferenceTarget extends SingleTargetVariableReferenceTarget<AbstractAction> {
		new(AbstractNamedReference reference, AbstractAction target) {
			super(reference, target)
		}
	}

	static class ParameterVariableReferenceTarget extends SingleTargetVariableReferenceTarget<Parameter> {
		new(AbstractNamedReference reference, Parameter target) {
			super(reference, target)
		}
	}
	
	/*
	 * ==========================================================================
	 * Helpers to identify targets of named references in data channel behaviours
	 * ==========================================================================
	 */
	
	def Iterable<VariableReferenceTarget> findTarget(AbstractNamedReference reference, DataChannelBehaviour dcBehaviour) {
		val referenceName = reference.referenceName
		val sinkRoleCandidates = new ArrayList
		for (dataSinkRole : dcBehaviour.dataSinks) {
			val roleName = dataSinkRole.entityName
			if (referenceName.startsWith(roleName + ".")) {
				val referenceTail = referenceName.substring(roleName.length + 1)
				val parameterName = dataSinkRole.dataInterface.dataSignature.parameter.parameterName
				if (referenceTail == parameterName) {
					sinkRoleCandidates += dataSinkRole
				}
			}
		}
		return sinkRoleCandidates.map[role | new DataSinkRoleReferenceTarget(reference, role)]
	}
	
	static class DataSinkRoleReferenceTarget extends SingleTargetVariableReferenceTarget<DataSinkRole> {
		new (AbstractNamedReference reference, DataSinkRole target) {
			super(reference, target)
		}
	}
	
	/*
	 * =====================================
	 * Utilities for target finding routines
	 * =====================================
	 */
	
	protected def findVariableDefinition(Iterable<VariableUsage> variableUsages, AbstractNamedReference reference) {
		variableUsages.findVariableDefinition(reference.referenceName)
	}
	
	protected def findVariableDefinition(Iterable<VariableUsage> variableUsages, String variableName) {
		for (variableUsage : variableUsages) {
			if (variableUsage.namedReference__VariableUsage.matchesName(variableName)) {
				return variableUsage;
			}
		}
		null
	}
	
	protected def matchesName(AbstractNamedReference reference, String referenceName) {
		reference.referenceName == referenceName
	}
	
}

package org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.provider.util;

import java.util.Optional;

import org.eclipse.emf.ecore.EObject;
import org.palladiosimulator.pcm.usagemodel.ScenarioBehaviour;

public interface ContainingScenarioBehaviorFinderMixin {

	default Optional<ScenarioBehaviour> getContainingScenarioBehavior(EObject eobject) {
		ContainmentWalker containmentWalker = new ContainmentWalker(eobject);
		return containmentWalker.findParentOfType(ScenarioBehaviour.class);
	}
	
}

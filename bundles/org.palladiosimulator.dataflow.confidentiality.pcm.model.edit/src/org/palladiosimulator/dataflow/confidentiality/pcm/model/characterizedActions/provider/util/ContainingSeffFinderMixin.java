package org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.provider.util;

import java.util.Optional;

import org.eclipse.emf.ecore.EObject;
import org.palladiosimulator.pcm.seff.ServiceEffectSpecification;

public interface ContainingSeffFinderMixin {

	default Optional<ServiceEffectSpecification> getContainingServiceEffectSpecification(EObject eobject) {
		ContainmentWalker containmentWalker = new ContainmentWalker(eobject);
		return containmentWalker.findParentOfType(ServiceEffectSpecification.class);
	}
	
}

package org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.provider.util;

import java.util.Collection;
import java.util.Collections;
import java.util.Optional;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.edit.provider.IItemPropertyDescriptor;
import org.palladiosimulator.pcm.seff.ExternalCallAction;

public interface AvailableExternalCallActionMixin extends ContainingSeffFinderMixin {

	default Optional<ExternalCallAction> getContainingExternalCallAction(EObject eobject) {
		return new ContainmentWalker(eobject).findParentOfType(ExternalCallAction.class);
	}
	
	default Optional<Collection<ExternalCallAction>> getAvailableExternalCallActions(EObject eobject) {
		return getContainingServiceEffectSpecification(eobject)
				.map(ContainmentWalker::new)
				.map(cw -> cw.findChildrenOfType(ExternalCallAction.class));
	}
	
	default IItemPropertyDescriptor getAvailableExternalCallActionsPropertyDescriptor(IItemPropertyDescriptor originalItemDescriptor) {
		return new ItemPropertyDescriptorDecorator(originalItemDescriptor) {

			@Override
			public Collection<?> getChoiceOfValues(Object thisObject) {
				return getAvailableExternalCallActions((EObject) thisObject).map(Collection.class::cast)
						.orElseGet(() -> Collections.emptyList());
			}

		};
	}
	
}

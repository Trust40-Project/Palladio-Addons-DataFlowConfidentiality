package org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.provider.util;

import java.util.Collection;
import java.util.Optional;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.edit.provider.IItemPropertyDescriptor;
import org.palladiosimulator.pcm.usagemodel.EntryLevelSystemCall;

public interface AvailableEntryLevelSystemCallActionMixin extends ContainingScenarioBehaviorFinderMixin {

	default Optional<Collection<EntryLevelSystemCall>> getAvailableEntryLevelSystemCalls(EObject eobject) {
		return getContainingScenarioBehavior(eobject)
				.map(ContainmentWalker::new)
				.map(cw -> cw.findChildrenOfType(EntryLevelSystemCall.class));
	}

	default IItemPropertyDescriptor getAvailableEntryLevelSystemCallsPropertyDescriptor(IItemPropertyDescriptor originalItemDescriptor) {
		return new ItemPropertyDescriptorDecorator(originalItemDescriptor) {

			@Override
			public Collection<?> getChoiceOfValues(Object thisObject) {
				return getAvailableEntryLevelSystemCalls((EObject) thisObject).map(Collection.class::cast)
						.orElseGet(() -> super.getChoiceOfValues(thisObject));
			}

		};
	}
	
}

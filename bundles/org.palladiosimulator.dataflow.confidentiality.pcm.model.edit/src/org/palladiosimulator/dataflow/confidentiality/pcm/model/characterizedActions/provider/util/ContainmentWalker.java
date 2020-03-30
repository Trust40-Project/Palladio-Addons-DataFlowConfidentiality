package org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.provider.util;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Optional;

import org.eclipse.emf.common.util.TreeIterator;
import org.eclipse.emf.ecore.EObject;

public class ContainmentWalker {

	private final EObject eobject;

	public ContainmentWalker(EObject eobject) {
		this.eobject = eobject;
	}
	
	@SuppressWarnings("unchecked")
	public <T extends EObject> Optional<T> findParentOfType(Class<T> clz) {
		EObject current = eobject;
		while (current != null && !clz.isInstance(current)) {
			current = current.eContainer();
		}
		return Optional.ofNullable((T)current);
	}
	
	@SuppressWarnings("unchecked")
	public <T extends EObject> Collection<T> findChildrenOfType(Class<T> clz) {
		Collection<T> foundChildren = new ArrayList<>();
		for (TreeIterator<EObject> iter = eobject.eAllContents(); iter.hasNext(); ) {
			EObject child = iter.next();
			if (clz.isInstance(child)) {
				foundChildren.add((T)child);
			}
		}
		return foundChildren;
	}
}

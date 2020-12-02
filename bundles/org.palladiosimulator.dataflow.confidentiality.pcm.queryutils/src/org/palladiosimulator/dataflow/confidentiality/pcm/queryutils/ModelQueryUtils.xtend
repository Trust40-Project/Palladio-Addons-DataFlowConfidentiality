package org.palladiosimulator.dataflow.confidentiality.pcm.queryutils

import org.eclipse.emf.ecore.EObject

class ModelQueryUtils {
	
	def <T> Iterable<T> findAllChildrenIncludingSelfOfType(EObject obj, Class<T> clz) {
		val results = obj.findChildrenOfType(clz).toList
		if (clz.isInstance(obj)) {
			results.add(obj as T)
		}
		results
	}
	
	def <T> Iterable<T> findChildrenOfType(EObject obj, Class<T> clz) {
		obj.eAllContents.filter(clz).toIterable
	}
	
	def <T> T findParentOfType(EObject obj, Class<T> clz, boolean includeSelf) {
		var currentObject = includeSelf ? obj : obj.eContainer
		for (; currentObject !== null && !clz.isInstance(currentObject); currentObject = currentObject.eContainer) {}
		currentObject as T
	}
}

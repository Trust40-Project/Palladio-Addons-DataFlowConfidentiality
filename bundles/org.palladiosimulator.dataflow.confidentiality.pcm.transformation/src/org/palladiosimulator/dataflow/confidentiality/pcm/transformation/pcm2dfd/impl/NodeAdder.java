package org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.impl;

import org.palladiosimulator.dataflow.diagram.DataFlowDiagram.Node;

@FunctionalInterface
public interface NodeAdder {

	default void addToDiagram(Node node) {
		if (node != null) {
			addToDiagramWithoutNullCheck(node);
		}
	}
	
	void addToDiagramWithoutNullCheck(Node node);
	
}

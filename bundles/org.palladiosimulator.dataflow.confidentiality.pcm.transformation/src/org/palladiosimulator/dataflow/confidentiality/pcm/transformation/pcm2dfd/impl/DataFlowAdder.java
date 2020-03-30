package org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.impl;

import org.palladiosimulator.dataflow.diagram.characterized.DataFlowDiagramCharacterized.CharacterizedDataFlow;

@FunctionalInterface
public interface DataFlowAdder {

	void addToDiagram(CharacterizedDataFlow flow);
	
}

package org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd;

import org.palladiosimulator.dataflow.diagram.DataFlowDiagram.DataFlowDiagram;
import org.palladiosimulator.dataflow.dictionary.DataDictionary.DataDictionary;

public interface TransformationResult {

	DataFlowDiagram getDiagram();
	
	DataDictionary getDictionary();

	TransformationTrace getTrace();

}
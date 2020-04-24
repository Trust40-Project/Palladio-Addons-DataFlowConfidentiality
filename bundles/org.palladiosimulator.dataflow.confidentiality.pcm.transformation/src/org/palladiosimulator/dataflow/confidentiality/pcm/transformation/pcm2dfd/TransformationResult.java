package org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd;

import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.trace.PCM2DFDTransformationTrace;
import org.palladiosimulator.dataflow.diagram.DataFlowDiagram.DataFlowDiagram;
import org.palladiosimulator.dataflow.dictionary.DataDictionary.DataDictionary;

public interface TransformationResult {

	DataFlowDiagram getDiagram();
	
	DataDictionary getDictionary();

	PCM2DFDTransformationTrace getTrace();

}
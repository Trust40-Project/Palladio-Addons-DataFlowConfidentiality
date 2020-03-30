package org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd;

import org.palladiosimulator.dataflow.diagram.DataFlowDiagram.DataFlowDiagram;

public interface TransformationResult {

	DataFlowDiagram getDiagram();

	TransformationTrace getTrace();

}
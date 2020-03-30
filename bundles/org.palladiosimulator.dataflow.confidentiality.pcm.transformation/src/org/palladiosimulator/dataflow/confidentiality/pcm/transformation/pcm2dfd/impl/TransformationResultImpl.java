package org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.impl;

import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.TransformationResult;
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.TransformationTrace;
import org.palladiosimulator.dataflow.diagram.DataFlowDiagram.DataFlowDiagram;

public class TransformationResultImpl implements TransformationResult {
	private final DataFlowDiagram diagram;
	private final TransformationTrace trace;

	public TransformationResultImpl(DataFlowDiagram diagram, TransformationTrace trace) {
		super();
		this.diagram = diagram;
		this.trace = trace;
	}

	@Override
	public DataFlowDiagram getDiagram() {
		return diagram;
	}

	@Override
	public TransformationTrace getTrace() {
		return trace;
	}

}
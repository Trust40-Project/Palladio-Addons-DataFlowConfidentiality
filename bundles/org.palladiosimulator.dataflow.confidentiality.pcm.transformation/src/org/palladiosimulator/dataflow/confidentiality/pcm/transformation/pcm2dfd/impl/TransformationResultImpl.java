package org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.impl;

import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.TransformationResult;
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.trace.PCM2DFDTransformationTrace;
import org.palladiosimulator.dataflow.diagram.DataFlowDiagram.DataFlowDiagram;
import org.palladiosimulator.dataflow.dictionary.DataDictionary.DataDictionary;

public class TransformationResultImpl implements TransformationResult {
	private final DataFlowDiagram diagram;
	private final DataDictionary dictionary;
	private final PCM2DFDTransformationTrace trace;

	public TransformationResultImpl(DataFlowDiagram diagram, DataDictionary dictionary, PCM2DFDTransformationTrace trace) {
		super();
		this.diagram = diagram;
		this.dictionary = dictionary;
		this.trace = trace;
	}

	@Override
	public DataFlowDiagram getDiagram() {
		return diagram;
	}

	@Override
	public PCM2DFDTransformationTrace getTrace() {
		return trace;
	}

	@Override
	public DataDictionary getDictionary() {
		return dictionary;
	}

}
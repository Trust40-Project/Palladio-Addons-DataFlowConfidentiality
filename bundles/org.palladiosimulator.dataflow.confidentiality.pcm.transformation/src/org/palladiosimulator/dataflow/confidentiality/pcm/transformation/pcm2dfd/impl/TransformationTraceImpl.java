package org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.impl;

import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.TransformationTrace;

import com.google.common.collect.ImmutableMultimap;
import com.google.common.collect.Multimap;
import com.google.common.collect.MultimapBuilder;

public class TransformationTraceImpl implements TransformationTrace, TraceRecorder {

	private final Multimap<String, String> srcToDst = MultimapBuilder.hashKeys().hashSetValues().build();
	private ImmutableMultimap<String, String> dstToSrc = null;
	
	@Override
	public void addToTrace(String srcId, String dstId) {
		srcToDst.put(srcId, dstId);
		dstToSrc = null;
	}

	@Override
	public Iterable<String> getDestinationIds(String srcId) {
		return srcToDst.get(srcId);
	}

	@Override
	public Iterable<String> getSourceIds(String dstId) {
		if (dstToSrc == null) {
			dstToSrc = ImmutableMultimap.copyOf(srcToDst).inverse();
		}
		return dstToSrc.get(dstId);
	}

}

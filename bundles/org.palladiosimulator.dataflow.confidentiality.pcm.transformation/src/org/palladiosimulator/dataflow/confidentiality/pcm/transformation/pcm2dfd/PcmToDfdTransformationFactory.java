package org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd;

import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.impl.PcmToDfdTransformationImpl;

public interface PcmToDfdTransformationFactory {

	default PcmToDfdTransformation create() {
		return new PcmToDfdTransformationImpl();
	}
	
}

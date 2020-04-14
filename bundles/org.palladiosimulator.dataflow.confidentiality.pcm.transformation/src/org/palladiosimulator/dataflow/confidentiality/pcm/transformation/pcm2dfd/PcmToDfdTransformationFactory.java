package org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd;

import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.impl.PcmToDfdTransformationImpl;

public class PcmToDfdTransformationFactory {

	public static PcmToDfdTransformation create() {
		return new PcmToDfdTransformationImpl();
	}
	
}

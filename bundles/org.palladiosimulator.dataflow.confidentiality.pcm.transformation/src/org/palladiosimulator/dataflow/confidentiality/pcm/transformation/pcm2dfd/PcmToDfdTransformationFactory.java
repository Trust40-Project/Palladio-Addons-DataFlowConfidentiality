package org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd;

import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.impl.PcmToDfdTransformationImplementation;

public class PcmToDfdTransformationFactory {

	public static PcmToDfdTransformation create() {
		return new PcmToDfdTransformationImplementation();
	}
	
}

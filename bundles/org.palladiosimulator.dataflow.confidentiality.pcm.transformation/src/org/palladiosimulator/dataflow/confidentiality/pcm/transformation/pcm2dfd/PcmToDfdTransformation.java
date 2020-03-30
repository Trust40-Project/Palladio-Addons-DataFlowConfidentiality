package org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd;

import org.palladiosimulator.pcm.usagemodel.UsageModel;

public interface PcmToDfdTransformation {

	public TransformationResult transform(UsageModel usageModel);

}

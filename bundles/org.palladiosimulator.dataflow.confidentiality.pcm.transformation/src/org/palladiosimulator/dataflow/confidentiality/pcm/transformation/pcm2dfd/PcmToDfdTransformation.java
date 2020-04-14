package org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd;

import java.util.Arrays;
import java.util.Collection;

import org.palladiosimulator.pcm.usagemodel.UsageModel;

public interface PcmToDfdTransformation {

	default public TransformationResult transform(UsageModel usageModel) {
		return transform(Arrays.asList(usageModel));
	}
	
	public TransformationResult transform(Collection<UsageModel> usageModels);

}

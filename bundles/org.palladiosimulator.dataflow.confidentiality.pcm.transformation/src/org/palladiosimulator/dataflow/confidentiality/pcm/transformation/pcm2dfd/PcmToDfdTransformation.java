package org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd;

import java.util.Arrays;
import java.util.Collection;

import org.palladiosimulator.pcm.allocation.Allocation;
import org.palladiosimulator.pcm.usagemodel.UsageModel;

public interface PcmToDfdTransformation {

    default public TransformationResult transform(UsageModel usageModel, Allocation allocationModel) {
        return transform(Arrays.asList(usageModel), allocationModel);
    }

    public TransformationResult transform(Collection<UsageModel> usageModels, Allocation allocationModel);

}

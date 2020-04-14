package org.palladiosimulator.dataflow.confidentiality.pcm.workflow.jobs;

import org.palladiosimulator.dataflow.confidentiality.transformation.workflow.blackboards.KeyValueMDSDBlackboard;

import de.uka.ipd.sdq.workflow.jobs.IBlackboardInteractingJob;

public interface TransformPCMDFDtoPrologJob<T extends KeyValueMDSDBlackboard> extends IBlackboardInteractingJob<T> {

    String getPrologKey();
    
}

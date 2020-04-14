package org.palladiosimulator.dataflow.confidentiality.pcm.workflow.jobs.impl;

import org.palladiosimulator.dataflow.confidentiality.pcm.workflow.jobs.TransformPCMDFDToPrologJobBuilder;
import org.palladiosimulator.dataflow.confidentiality.transformation.workflow.blackboards.KeyValueMDSDBlackboard;

import de.uka.ipd.sdq.workflow.jobs.SequentialBlackboardInteractingJob;

/**
 * This class does not contain any logic but provides a nicely named container for a sequence of
 * steps that implements the required interface.
 * 
 * External logic has to inser the jobs and build the logic. Use {@link #newBuilder()} to acquire a
 * builder for a meaningful instance of this calss.
 *
 * @param <T>
 *            The blackboard type to be used.
 */
public class TransformPCMDFDtoPrologJobImpl<T extends KeyValueMDSDBlackboard>
        extends SequentialBlackboardInteractingJob<T>
        implements org.palladiosimulator.dataflow.confidentiality.pcm.workflow.jobs.TransformPCMDFDtoPrologJob<T> {

    private final String prologKey;

    public TransformPCMDFDtoPrologJobImpl(String name, String prologKey) {
        super(name);
        this.prologKey = prologKey;
    }

    public static TransformPCMDFDToPrologJobBuilder newBuilder() {
        return new TransformPCMDFDToPrologJobBuilder();
    }

    @Override
    public String getPrologKey() {
        return prologKey;
    }
}

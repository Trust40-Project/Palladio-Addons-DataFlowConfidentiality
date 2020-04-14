package org.palladiosimulator.dataflow.confidentiality.pcm.workflow;

import org.eclipse.core.runtime.IProgressMonitor;
import org.palladiosimulator.dataflow.confidentiality.pcm.workflow.impl.TransformPCMDFDToPrologWorkflowImpl;
import org.palladiosimulator.dataflow.confidentiality.pcm.workflow.jobs.TransformPCMDFDToPrologJobBuilder;
import org.palladiosimulator.dataflow.confidentiality.pcm.workflow.jobs.TransformPCMDFDtoPrologJob;
import org.palladiosimulator.dataflow.confidentiality.transformation.workflow.blackboards.KeyValueMDSDBlackboard;

import de.uka.ipd.sdq.workflow.WorkflowExceptionHandler;

public class TransformPCMDFDToPrologWorkflowFactory {

    private TransformPCMDFDToPrologWorkflowFactory() {
        // intentionally left blank
    }

    /**
     * Constructs a new transformation workflow. See {@link TransformPCMDFDToPrologJobBuilder} for
     * how to create the required job.
     * 
     * Runtime exceptions might be thrown during execution. If you want to handle them gracefully,
     * refer to
     * {@link #createWorkflow(TransformPCMDFDtoPrologJob, IProgressMonitor, WorkflowExceptionHandler)}.
     * 
     * @param job
     *            The job to execute within the workflow.
     * @return The executable workflow.
     */
    public static TransformPCMDFDToPrologWorkflow createWorkflow(
            TransformPCMDFDtoPrologJob<? extends KeyValueMDSDBlackboard> job) {
        return new TransformPCMDFDToPrologWorkflowImpl(job);
    }

    /**
     * Constructs a new transformation workflow. See {@link TransformPCMDFDToPrologJobBuilder} for
     * how to create the required job.
     * 
     * @param job
     *            The job to execute within the workflow.
     * @param monitor
     *            A monitor for monitoring the progress of the workflow execution.
     * @param handler
     *            A handler for workflow exceptions.
     * @return The executable workflow.
     */
    public static TransformPCMDFDToPrologWorkflow createWorkflow(
            TransformPCMDFDtoPrologJob<? extends KeyValueMDSDBlackboard> job, IProgressMonitor monitor,
            WorkflowExceptionHandler handler) {
        return new TransformPCMDFDToPrologWorkflowImpl(job, monitor, handler);
    }

}

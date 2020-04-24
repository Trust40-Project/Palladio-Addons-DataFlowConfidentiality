package org.palladiosimulator.dataflow.confidentiality.pcm.workflow.jobs;

import org.eclipse.core.runtime.IProgressMonitor;
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.trace.PCM2DFDTransformationTrace;
import org.palladiosimulator.dataflow.confidentiality.pcm.workflow.impl.TransitiveTransformationTraceImpl;
import org.palladiosimulator.dataflow.confidentiality.transformation.workflow.blackboards.KeyValueMDSDBlackboard;

import de.uka.ipd.sdq.workflow.jobs.AbstractBlackboardInteractingJob;
import de.uka.ipd.sdq.workflow.jobs.CleanupFailedException;
import de.uka.ipd.sdq.workflow.jobs.JobFailedException;
import de.uka.ipd.sdq.workflow.jobs.UserCanceledException;

public class TransitiveTransformationTraceBuilderJob extends AbstractBlackboardInteractingJob<KeyValueMDSDBlackboard> {

    private final String pcmTraceKey;
    private final String dfdTraceKey;
    private final String transitiveTraceKey;

    public TransitiveTransformationTraceBuilderJob(String pcmTraceKey, String dfdTraceKey, String transitiveTraceKey) {
        this.pcmTraceKey = pcmTraceKey;
        this.dfdTraceKey = dfdTraceKey;
        this.transitiveTraceKey = transitiveTraceKey;
    }

    @Override
    public void execute(IProgressMonitor monitor) throws JobFailedException, UserCanceledException {
        monitor.beginTask("Create transitive transformation trace.", 3);
        
        var pcmTrace = getBlackboard().get(pcmTraceKey)
            .filter(PCM2DFDTransformationTrace.class::isInstance)
            .map(PCM2DFDTransformationTrace.class::cast)
            .orElseThrow(() -> new JobFailedException("The PCM2DFD trace is not available."));
        monitor.worked(1);

        var dfdTrace = getBlackboard().get(dfdTraceKey)
            .filter(org.palladiosimulator.dataflow.confidentiality.transformation.workflow.DFD2PrologTransformationTrace.class::isInstance)
            .map(org.palladiosimulator.dataflow.confidentiality.transformation.workflow.DFD2PrologTransformationTrace.class::cast)
            .orElseThrow(() -> new JobFailedException("The DFD2Prolog trace is not available."));
        monitor.worked(1);

        var transitiveTrace = new TransitiveTransformationTraceImpl(pcmTrace, dfdTrace);
        getBlackboard().put(transitiveTraceKey, transitiveTrace);
        monitor.worked(1);

        monitor.done();
    }

    @Override
    public void cleanup(IProgressMonitor monitor) throws CleanupFailedException {
        // nothing to do here
    }

    @Override
    public String getName() {
        return "transitive trace build";
    }

}

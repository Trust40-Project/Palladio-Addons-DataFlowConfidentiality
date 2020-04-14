package org.palladiosimulator.dataflow.confidentiality.pcm.workflow.jobs;

import java.util.Collection;
import java.util.stream.Collectors;

import org.apache.commons.lang3.Validate;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.emf.ecore.resource.Resource;
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.PcmToDfdTransformation;
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.PcmToDfdTransformationFactory;
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.TransformationResult;
import org.palladiosimulator.pcm.usagemodel.UsageModel;

import de.uka.ipd.sdq.workflow.jobs.AbstractBlackboardInteractingJob;
import de.uka.ipd.sdq.workflow.jobs.CleanupFailedException;
import de.uka.ipd.sdq.workflow.jobs.JobFailedException;
import de.uka.ipd.sdq.workflow.jobs.UserCanceledException;
import de.uka.ipd.sdq.workflow.mdsd.blackboard.MDSDBlackboard;
import de.uka.ipd.sdq.workflow.mdsd.blackboard.ModelLocation;
import de.uka.ipd.sdq.workflow.mdsd.blackboard.ResourceSetPartition;

public class TransformPCMtoDFDJob extends AbstractBlackboardInteractingJob<MDSDBlackboard> {

    private final String usageModelPartitionId;
    private final ModelLocation dfdLocation;
    private final ModelLocation ddLocation;

    public TransformPCMtoDFDJob(String usageModelPartitionId, ModelLocation dfdLocation, ModelLocation ddLocation) {
        Validate.notNull(dfdLocation);
        Validate.notNull(ddLocation);
        Validate.isTrue(dfdLocation.getPartitionID()
            .equals(ddLocation.getPartitionID()), "Partition ids of transformation results have to be equal.");
        this.usageModelPartitionId = usageModelPartitionId;
        this.dfdLocation = dfdLocation;
        this.ddLocation = ddLocation;
    }

    @Override
    public void execute(IProgressMonitor monitor) throws JobFailedException, UserCanceledException {
        monitor.beginTask("Transformation", 3);

        // find all usage models
        ResourceSetPartition usageModelPartition = getBlackboard().getPartition(usageModelPartitionId);
        Collection<UsageModel> usageModels = usageModelPartition.getResourceSet()
            .getResources()
            .stream()
            .map(Resource::getContents)
            .flatMap(Collection::stream)
            .filter(UsageModel.class::isInstance)
            .map(UsageModel.class::cast)
            .collect(Collectors.toList());
        monitor.worked(1);

        // carry out transformation
        PcmToDfdTransformation transformation = PcmToDfdTransformationFactory.create();
        TransformationResult result = transformation.transform(usageModels);
        monitor.worked(1);

        // save results to blackboard
        if (!getBlackboard().hasPartition(ddLocation.getPartitionID())) {
            getBlackboard().addPartition(ddLocation.getPartitionID(), new ResourceSetPartition());
        }
        ResourceSetPartition dfdPartition = getBlackboard().getPartition(ddLocation.getPartitionID());
        dfdPartition.setContents(ddLocation.getModelID(), result.getDictionary());
        dfdPartition.setContents(dfdLocation.getModelID(), result.getDiagram());

        monitor.worked(1);
        monitor.done();
    }

    @Override
    public void cleanup(IProgressMonitor monitor) throws CleanupFailedException {
        // nothing to do here
    }

    @Override
    public String getName() {
        return "Transform PCM to DFD";
    }

}

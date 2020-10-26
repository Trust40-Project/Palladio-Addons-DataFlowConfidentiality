package org.palladiosimulator.dataflow.confidentiality.pcm.workflow.jobs;

import java.util.Collection;
import java.util.stream.Collectors;

import org.apache.commons.lang3.Validate;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.PcmToDfdTransformation;
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.PcmToDfdTransformationFactory;
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.TransformationResult;
import org.palladiosimulator.dataflow.confidentiality.transformation.workflow.blackboards.KeyValueMDSDBlackboard;
import org.palladiosimulator.pcm.allocation.Allocation;
import org.palladiosimulator.pcm.usagemodel.UsageModel;

import de.uka.ipd.sdq.workflow.jobs.AbstractBlackboardInteractingJob;
import de.uka.ipd.sdq.workflow.jobs.CleanupFailedException;
import de.uka.ipd.sdq.workflow.jobs.JobFailedException;
import de.uka.ipd.sdq.workflow.jobs.UserCanceledException;
import de.uka.ipd.sdq.workflow.mdsd.blackboard.ModelLocation;
import de.uka.ipd.sdq.workflow.mdsd.blackboard.ResourceSetPartition;

public class TransformPCMtoDFDJob extends AbstractBlackboardInteractingJob<KeyValueMDSDBlackboard> {

    private final String pcmModelsPartitionId;
    private final ModelLocation dfdLocation;
    private final ModelLocation ddLocation;
    private final String traceKey;

    public TransformPCMtoDFDJob(String pcmModelsPartitionId, ModelLocation dfdLocation, ModelLocation ddLocation,
            String traceKey) {
        Validate.notNull(dfdLocation);
        Validate.notNull(ddLocation);
        Validate.notEmpty(traceKey);
        Validate.isTrue(dfdLocation.getPartitionID()
            .equals(ddLocation.getPartitionID()), "Partition ids of transformation results have to be equal.");
        this.pcmModelsPartitionId = pcmModelsPartitionId;
        this.dfdLocation = dfdLocation;
        this.ddLocation = ddLocation;
        this.traceKey = traceKey;
    }

    @Override
    public void execute(IProgressMonitor monitor) throws JobFailedException, UserCanceledException {
        monitor.beginTask("Transformation", 3);

        // find all usage models and the allocation model
        var pcmModelsPartition = getBlackboard().getPartition(pcmModelsPartitionId);
        var allPcmContents = pcmModelsPartition.getResourceSet()
            .getResources()
            .stream()
            .map(Resource::getContents)
            .flatMap(Collection::stream)
            .collect(Collectors.toList());
        var usageModels = filter(allPcmContents, UsageModel.class);
        var allocationModels = filter(allPcmContents, Allocation.class);
        if (allocationModels.size() != 1) {
            throw new JobFailedException("There is not exactly one allocation model in the input model partition.");
        }
        var allocationModel = allocationModels.iterator()
            .next();
        monitor.worked(1);

        // carry out transformation
        PcmToDfdTransformation transformation = PcmToDfdTransformationFactory.create();
        TransformationResult result = transformation.transform(usageModels, allocationModel);
        monitor.worked(1);

        // save results to blackboard
        if (!getBlackboard().hasPartition(ddLocation.getPartitionID())) {
            getBlackboard().addPartition(ddLocation.getPartitionID(), new ResourceSetPartition());
        }
        ResourceSetPartition dfdPartition = getBlackboard().getPartition(ddLocation.getPartitionID());
        dfdPartition.setContents(ddLocation.getModelID(), result.getDictionary());
        dfdPartition.setContents(dfdLocation.getModelID(), result.getDiagram());

        // save trace
        getBlackboard().put(traceKey, result.getTrace());

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

    protected static <T extends EObject> Collection<T> filter(Collection<EObject> collection, Class<T> type) {
        return collection.stream()
            .filter(type::isInstance)
            .map(type::cast)
            .collect(Collectors.toList());
    }

}

package org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage;

import java.util.HashMap;
import java.util.Map;

import org.eclipse.core.runtime.IProgressMonitor;
import org.palladiosimulator.pcm.usagemodel.EntryLevelSystemCall;

public interface DataTypeUsageAnalysis {

    String getName();

    String getUUID();

    DataTypeUsageAnalysisResult getUsedDataTypes(EntryLevelSystemCall elsc, IProgressMonitor monitor)
            throws InterruptedException;

    default Map<EntryLevelSystemCall, DataTypeUsageAnalysisResult> getUsedDataTypes(
            Iterable<EntryLevelSystemCall> elscs, IProgressMonitor monitor) throws InterruptedException {
        Map<EntryLevelSystemCall, DataTypeUsageAnalysisResult> result = new HashMap<>();
        for (var elsc : elscs) {
            result.put(elsc, getUsedDataTypes(elsc, monitor));
        }
        return result;
    }
}

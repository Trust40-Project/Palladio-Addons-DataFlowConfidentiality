package org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage;

import java.util.Collection;
import java.util.HashMap;
import java.util.Map;

import org.eclipse.core.runtime.IProgressMonitor;
import org.palladiosimulator.pcm.usagemodel.EntryLevelSystemCall;

public interface DataTypeUsageAnalysis {

    String getName();

    String getUUID();

    Collection<DataTypeUsageAnalysisResult> getUsedDataTypes(EntryLevelSystemCall elsc, IProgressMonitor monitor)
            throws InterruptedException;

    default Map<EntryLevelSystemCall, Collection<DataTypeUsageAnalysisResult>> getUsedDataTypes(
            Iterable<EntryLevelSystemCall> elscs, IProgressMonitor monitor) throws InterruptedException {
        Map<EntryLevelSystemCall, Collection<DataTypeUsageAnalysisResult>> result = new HashMap<>();
        for (var elsc : elscs) {
            result.put(elsc, getUsedDataTypes(elsc, monitor));
        }
        return result;
    }
}

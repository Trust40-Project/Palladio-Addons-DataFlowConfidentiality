package org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage;

import java.util.Map;

import org.palladiosimulator.pcm.usagemodel.EntryLevelSystemCall;

public interface DataTypeUsageAnalysis {

    String getName();
    
    String getUUID();
    
    DataTypeUsageAnalysisResult getUsedDataTypes(EntryLevelSystemCall elsc);

    Map<EntryLevelSystemCall, DataTypeUsageAnalysisResult> getUsedDataTypes(Iterable<EntryLevelSystemCall> elscs);
}

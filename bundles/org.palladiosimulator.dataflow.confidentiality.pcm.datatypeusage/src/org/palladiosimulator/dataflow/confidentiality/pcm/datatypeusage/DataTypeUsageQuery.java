package org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage;

import java.util.Map;

import org.palladiosimulator.pcm.usagemodel.EntryLevelSystemCall;

public interface DataTypeUsageQuery {

    DataTypeUsageQueryResult getUsedDataTypes(EntryLevelSystemCall elsc);

    Map<EntryLevelSystemCall, DataTypeUsageQueryResult> getUsedDataTypes(Iterable<EntryLevelSystemCall> elscs);
}

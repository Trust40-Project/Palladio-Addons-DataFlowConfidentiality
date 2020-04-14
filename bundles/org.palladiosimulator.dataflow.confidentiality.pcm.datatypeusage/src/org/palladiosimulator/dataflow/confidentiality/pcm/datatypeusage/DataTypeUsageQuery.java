package org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage;

import org.palladiosimulator.pcm.usagemodel.EntryLevelSystemCall;

public interface DataTypeUsageQuery {

    DataTypeUsageQueryResult getUsedDataTypes(EntryLevelSystemCall elsc);

}

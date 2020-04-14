package org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage;

import java.util.Collection;

import org.palladiosimulator.pcm.repository.DataType;

public interface DataTypeUsageQueryResult {

    Collection<DataType> getReadDataTypes();
    
    Collection<DataType> getWriteDataTypes();
    
}

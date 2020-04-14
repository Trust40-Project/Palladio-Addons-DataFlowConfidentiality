package org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.impl

import java.util.Collection
import org.eclipse.xtend.lib.annotations.Data
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.DataTypeUsageQueryResult
import org.palladiosimulator.pcm.repository.DataType

@Data
class DataTypeUsageQueryResultImpl implements DataTypeUsageQueryResult {
	val Collection<DataType> readDataTypes
	val Collection<DataType> writeDataTypes
}
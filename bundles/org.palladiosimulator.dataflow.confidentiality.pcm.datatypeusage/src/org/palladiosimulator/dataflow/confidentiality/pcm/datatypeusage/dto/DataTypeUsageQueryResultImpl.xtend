package org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.dto

import java.util.Collection
import org.eclipse.xtend.lib.annotations.Data
import org.palladiosimulator.pcm.repository.DataType
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.DataTypeUsageAnalysisResult

@Data
class DataTypeUsageQueryResultImpl implements DataTypeUsageAnalysisResult {
	val Collection<DataType> readDataTypes
	val Collection<DataType> writeDataTypes
}

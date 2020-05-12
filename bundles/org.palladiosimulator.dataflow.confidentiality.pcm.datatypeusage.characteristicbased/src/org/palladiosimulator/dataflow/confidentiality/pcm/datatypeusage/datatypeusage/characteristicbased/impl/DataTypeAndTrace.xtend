package org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.datatypeusage.characteristicbased.impl

import java.util.Collection
import org.eclipse.xtend.lib.annotations.Data

@Data
class DataTypeAndTrace {
	val Collection<String> dataTypeIds
	val Collection<Collection<String>> dataFlowIds
}
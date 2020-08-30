package org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.datatypeusage.characteristicbased.impl

import java.util.Collection
import org.eclipse.xtend.lib.annotations.Data

@Data
class DataTypeAndTrace {
	val Collection<String> dataTypeIds
	/**
	 * Contains nested lists of strings
	 */
	val Collection<Object> dataFlowIds
}
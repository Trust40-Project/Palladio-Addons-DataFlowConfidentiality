package org.palladiosimulator.dataflow.confidentiality.pcm.queryutils

import java.util.Stack
import org.eclipse.xtend.lib.annotations.Data
import org.palladiosimulator.indirections.actions.DataAction
import org.palladiosimulator.indirections.repository.DataSinkRole
import org.palladiosimulator.pcm.core.composition.AssemblyContext

@Data
class DataActionWithContext implements OutgoingDataDestination {
	val DataAction dataAction
	val DataSinkRole dataSinkRole
	val Stack<AssemblyContext> context
}

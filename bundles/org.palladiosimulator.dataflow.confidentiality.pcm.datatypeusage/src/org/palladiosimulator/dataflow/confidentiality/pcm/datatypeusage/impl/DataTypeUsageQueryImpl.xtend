package org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.impl

import java.util.Collection
import java.util.HashSet
import java.util.LinkedList
import org.eclipse.core.runtime.IProgressMonitor
import org.osgi.service.component.annotations.Component
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.DataTypeUsageAnalysis
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.DataTypeUsageAnalysisResult.EmptyDataFlowGraph
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.dto.DataTypeUsageQueryResultImpl
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.repository.DBOperationInterface
import org.palladiosimulator.dataflow.confidentiality.pcm.queryutilsorg.palladiosimulator.dataflow.confidentiality.pcm.queryutils.ModelQueryUtils
import org.palladiosimulator.dataflow.confidentiality.pcm.queryutilsorg.palladiosimulator.dataflow.confidentiality.pcm.queryutils.PcmQueryUtils
import org.palladiosimulator.dataflow.confidentiality.pcm.queryutilsorg.palladiosimulator.dataflow.confidentiality.pcm.queryutils.SeffWithContext
import org.palladiosimulator.pcm.repository.DataType
import org.palladiosimulator.pcm.repository.OperationSignature
import org.palladiosimulator.pcm.repository.PrimitiveDataType
import org.palladiosimulator.pcm.seff.ExternalCallAction
import org.palladiosimulator.pcm.usagemodel.EntryLevelSystemCall

@Component
class DataTypeUsageQueryImpl implements DataTypeUsageAnalysis {

	val extension PcmQueryUtils pcmQueryUtils = new PcmQueryUtils
	val extension ModelQueryUtils modelQueryUtils = new ModelQueryUtils

	override getName() {
		"Usage Query (Stopping at Store)"
	}
	
	override getUUID() {
		"5bf1aea9-5eb0-4a9b-91a4-01d322bb34df"
	}

	override getUsedDataTypes(EntryLevelSystemCall elsc, IProgressMonitor monitor) {
		val Collection<DataType> readData = new HashSet
		val Collection<DataType> writeData = new HashSet

		val signature = elsc.operationSignature__EntryLevelSystemCall
		val providedRole = elsc.providedRole_EntryLevelSystemCall
		val calledSeff = providedRole.findCalledSeff(signature, #[])

		readData.addDataTypes(signature)

		val seffQueue = new LinkedList<SeffWithContext>()
		seffQueue.add(calledSeff)
		while (!seffQueue.isEmpty) {
			val seff = seffQueue.pop
			for (eca : seff.seff.findChildrenOfType(ExternalCallAction)) {
				val calledSignature = eca.calledService_ExternalService
				readData.addDataTypes(calledSignature)
				if (calledSignature.interface__OperationSignature instanceof DBOperationInterface) {
					calledSignature.handleDBSignatureCall(elsc, seff, eca, readData, writeData)
				}
				val requiredRole = eca.role_ExternalService
				seffQueue.add(requiredRole.findCalledSeff(calledSignature, seff.context))
			}
		}

		readData.cleanup
		writeData.cleanup

		#[new DataTypeUsageQueryResultImpl(readData, writeData, EmptyDataFlowGraph.INSTANCE)]
	}
	
	protected def void handleDBSignatureCall(OperationSignature calledSignature, EntryLevelSystemCall elsc,
		SeffWithContext seff, ExternalCallAction eca, Collection<DataType> readData, Collection<DataType> writeData) {
		writeData.addDataTypes(calledSignature.parameters__OperationSignature.map[dataType__Parameter])
	}

	protected def void addDataTypes(Collection<DataType> dataTypes, Iterable<DataType> toAdd) {
		dataTypes.addAll(toAdd)
	}

	protected def void addDataTypes(Collection<DataType> dataTypes, OperationSignature signature) {
		dataTypes.addAll(signature.parameters__OperationSignature.map[dataType__Parameter])
		dataTypes.add(signature.returnType__OperationSignature)
	}

	protected def void cleanup(Collection<DataType> dataTypes) {
		dataTypes.remove(null)
		val equalTypeSets = dataTypes.filter(PrimitiveDataType).groupBy[type].filter[key, value|value.size > 1].values
		for (equalTypeSet : equalTypeSets) {
			val toRemove = equalTypeSet.subList(1, equalTypeSet.size)
			dataTypes.removeAll(toRemove)
		}
	}

}

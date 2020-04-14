package org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.impl

import java.util.Collection
import java.util.HashSet
import java.util.LinkedList
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.DataTypeUsageQuery
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.repository.DBOperationInterface
import org.palladiosimulator.dataflow.confidentiality.pcm.queryutilsorg.palladiosimulator.dataflow.confidentiality.pcm.queryutils.ModelQueryUtils
import org.palladiosimulator.dataflow.confidentiality.pcm.queryutilsorg.palladiosimulator.dataflow.confidentiality.pcm.queryutils.PcmQueryUtils
import org.palladiosimulator.dataflow.confidentiality.pcm.queryutilsorg.palladiosimulator.dataflow.confidentiality.pcm.queryutils.SeffWithContext
import org.palladiosimulator.pcm.repository.DataType
import org.palladiosimulator.pcm.repository.OperationSignature
import org.palladiosimulator.pcm.repository.PrimitiveDataType
import org.palladiosimulator.pcm.seff.ExternalCallAction
import org.palladiosimulator.pcm.usagemodel.EntryLevelSystemCall

class DataTypeUsageQueryImpl implements DataTypeUsageQuery {

	val extension PcmQueryUtils pcmQueryUtils = new PcmQueryUtils
	val extension ModelQueryUtils modelQueryUtils = new ModelQueryUtils

	override getUsedDataTypes(EntryLevelSystemCall elsc) {
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
					writeData.addDataTypes(calledSignature.parameters__OperationSignature.map[dataType__Parameter])
				}
				val requiredRole = eca.role_ExternalService
				seffQueue.add(requiredRole.findCalledSeff(calledSignature, seff.context))
			}
		}

		readData.cleanup
		writeData.cleanup

		new DataTypeUsageQueryResultImpl(readData, writeData)
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

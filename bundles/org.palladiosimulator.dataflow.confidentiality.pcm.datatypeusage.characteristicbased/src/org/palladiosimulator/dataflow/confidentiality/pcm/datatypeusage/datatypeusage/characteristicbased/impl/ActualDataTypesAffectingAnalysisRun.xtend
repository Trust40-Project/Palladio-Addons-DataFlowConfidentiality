package org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.datatypeusage.characteristicbased.impl

import java.util.Collection
import java.util.HashMap
import java.util.HashSet
import java.util.Map
import org.palladiosimulator.dataflow.confidentiality.defaultmodels.DefaultModelConstants
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.dto.DataTypeUsageQueryResultImpl
import org.palladiosimulator.dataflow.confidentiality.pcm.workflow.TransitiveTransformationTrace
import org.palladiosimulator.pcm.repository.DataType
import org.palladiosimulator.pcm.usagemodel.EntryLevelSystemCall
import org.prolog4j.Solution
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.trace.PCMSingleTraceElement

class ActualDataTypesAffectingAnalysisRun extends AnalysisRunBase {

	new(Iterable<EntryLevelSystemCall> elscs) {
		super(elscs)
	}

	protected override performAnalysisForNode(String nodeId, TransitiveTransformationTrace trace) {
		val query = nodeId.buildAnalysisQuery(trace)
		val querySolution = query.solve()
		if (!querySolution.isSuccess) {
			return new DataTypeUsageQueryResultImpl(#[], #[])
		}

		val dataTypesPerNode = querySolution.dataTypesPerNode
		dataTypesPerNode.createDataTypeUsageResult(trace)
	}

	protected def createDataTypeUsageResult(Map<String, Collection<String>> dataTypesPerNode,
		TransitiveTransformationTrace trace) {
		val readDataTypes = new HashSet<DataType>()
		val writeDataTypes = new HashSet<DataType>()
		for (processId : dataTypesPerNode.keySet) {
			val dataTypes = dataTypesPerNode.get(processId).flatMap[id|trace.getPCMEntries(id)].filter(
				PCMSingleTraceElement).map[element].filter(DataType).toSet
			readDataTypes += dataTypes
			if (processId.isStore) {
				writeDataTypes += dataTypes
			}
		}
		new DataTypeUsageQueryResultImpl(readDataTypes, writeDataTypes)
	}

	protected def getDataTypesPerNode(Solution<Object> solution) {
		val dataTypLiterals = new HashMap<String, Collection<String>>();
		for (var solutionIter = solution.iterator; solutionIter.hasNext; solutionIter.next) {
			val processId = solutionIter.get("P")
			val dataTypeLiterals = dataTypLiterals.computeIfAbsent(processId, [new HashSet<String>])
			dataTypeLiterals += solutionIter.get("DTS") as Collection<String>
		}
		dataTypLiterals
	}

	protected def buildAnalysisQuery(String nodeId, TransitiveTransformationTrace trace) {
		val traversedNodeCharacteristicTypeId = trace.getFactId([ ct |
			ct.id == DefaultModelConstants.CT_TRAVERSED_NODES_ID
		]).head
//		val influencingDataTypesCharacteristicTypeId = trace.getFactId([ ct |
//			ct.id == org.palladiosimulator.dataflow.confidentiality.pcm.resources.DefaultModelConstants.
//				CT_INFLUENCING_DATATYPES_ID
//		]).head
		val actualDataTypesCharacteristicTypeId = trace.getFactId([ ct |
			ct.id == org.palladiosimulator.dataflow.confidentiality.pcm.resources.DefaultModelConstants.
				CT_ACTUAL_DATATYPE_ID
		]).head

		val query = prover.query('''
			CTNODE = ?CTNODE,
			VNODE = ?VNODE,
			CTDTS = ?CTDTS,
			inputPin(P, PIN),
			characteristic(P, PIN, CTNODE, VNODE, S),
			setof(X, characteristic(P, PIN, CTDTS, X, S), DTS).
		''')
		query.bind("J$CTNODE", traversedNodeCharacteristicTypeId)
		query.bind("J$VNODE", nodeId)
		query.bind("J$CTDTS", actualDataTypesCharacteristicTypeId)
		query
	}

}

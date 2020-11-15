package org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.datatypeusage.characteristicbased.impl

import java.util.ArrayList
import java.util.Collection
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.DataTypeUsageAnalysisResult
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.dto.DataTypeUsageQueryResultImpl
import org.palladiosimulator.dataflow.confidentiality.pcm.workflow.TransitiveTransformationTrace
import org.palladiosimulator.pcm.usagemodel.EntryLevelSystemCall
import org.prolog4j.Query
import java.util.LinkedList

class ActualDataTypesAtELSCsAnalysisRun extends AnalysisRunBase {

	new(Iterable<EntryLevelSystemCall> elscs) {
		super(elscs)
	}

	override protected performAnalysisForNode(String nodeId, TransitiveTransformationTrace trace) {
		val readDataTypeResult = nodeId.buildAnalysisQueryForReadData(trace).executeQueryForDataTypes
		val writeDataTypeResult = nodeId.buildAnalysisQueryForWrittenData(trace).executeQueryForDataTypes
		buildDataTypeUsageQueryResult(readDataTypeResult, writeDataTypeResult, trace)
	}

	protected def buildAnalysisQueryForWrittenData(String nodeId, TransitiveTransformationTrace trace) {
		// hacky solution
		if (nodeId.toLowerCase.contains("entry")) {
			return nodeId.buildAnalysisQueryForWrittenDataReal(trace)
		} else {
			return nodeId.buildAnalysisQueryForDataDummy(trace)
		}
	}

	protected def buildAnalysisQueryForWrittenDataReal(String nodeId, TransitiveTransformationTrace trace) {
		val query = prover.query('''
			CTNODE = ?CTNODE2,
			VNODE = ?VNODE2,
			CTDTS = ?CTDTS2,
			store(P),
			inputPin(P, PIN),
			characteristic(P, PIN, CTNODE, VNODE, S),
			setof_characteristics(P, PIN, CTDTS, DTS, S).
		''')
		query.bind("CTNODE2", trace.traversedNodesCharacteristicTypeId)
		query.bind("VNODE2", nodeId)
		query.bind("CTDTS2", trace.actualDataTypesCharacteristicTypeId)
		query
	}

	protected def buildAnalysisQueryForReadData(String nodeId, TransitiveTransformationTrace trace) {
		// hacky solution
		if (nodeId.toLowerCase.contains("entry")) {
			return nodeId.buildAnalysisQueryForDataDummy(trace)
		} else {
			return nodeId.buildAnalysisQueryForReadDataReal(trace)
		}
	}

	protected def buildAnalysisQueryForDataDummy(String nodeId, TransitiveTransformationTrace trace) {
		prover.query("TMP = [], DTS = TMP, S = TMP.")
	}

	protected def buildAnalysisQueryForReadDataReal(String nodeId, TransitiveTransformationTrace trace) {
		val query = prover.query('''
			CTDTS = ?CTDTS2,
			VNODE = ?VNODE2,
			nodeLiteral(VNODE, P),
			(
				inputPin(P, PIN);
				outputPin(P, PIN)
			),
			setof_characteristics(P, PIN, CTDTS, DTS, S).
		''')
		query.bind("CTDTS2", trace.actualDataTypesCharacteristicTypeId)
		query.bind("VNODE2", nodeId)
		query
	}

	protected def executeQueryForDataTypes(Query query) {
		val queryResults = query.executeQuery(#{"DTS" -> Collection, "S" -> Collection})
		val results = new ArrayList()
		for (queryResult : queryResults) {
			val dataTypeIds = queryResult.get("DTS") as Collection<String>
			val traceids = queryResult.get("S") as Collection<Object>
			val dataTypeAndTrace = new DataTypeAndTrace(dataTypeIds, traceids)
			results += dataTypeAndTrace
		}
		results
	}
	
	protected def buildDataTypeUsageQueryResult(Collection<DataTypeAndTrace> readDataTypeResult, Collection<DataTypeAndTrace> writeDataTypeResult, TransitiveTransformationTrace trace) {
		val Collection<DataTypeUsageAnalysisResult> result = new ArrayList
		val readByFlows = readDataTypeResult.groupBy[dataFlowIds]
		val writeByFlows = writeDataTypeResult.groupBy[dataFlowIds]
		val keys = (readByFlows.keySet + writeByFlows.keySet).toSet
		for (key : keys) {
			val readDataTypes = readByFlows.getOrDefault(key, #[]).flatMap[dataTypeIds].map[getDataType(trace)].toSet
			val writeDataTypes = writeByFlows.getOrDefault(key, #[]).flatMap[dataTypeIds].map[getDataType(trace)].toSet
			val dataFlowGraph = key.getDataFlowIds.getDataFlowGraph(trace)
			result += new DataTypeUsageQueryResultImpl(readDataTypes, writeDataTypes, dataFlowGraph)
		}
		result
	}

	protected def getDataFlowIds(Collection<Object> dataFlowPath) {
		val result = new ArrayList
		val queue = new LinkedList
		queue += dataFlowPath
		while (!queue.isEmpty) {
			val element = queue.pop
			if (element instanceof String) {
				result += element
			} else if (element instanceof Collection) {
				queue += element
			} else {
				throw new IllegalArgumentException("The data flow path contains an element of a wrong type: " + element.class)
			}
		}
		result
	}

}

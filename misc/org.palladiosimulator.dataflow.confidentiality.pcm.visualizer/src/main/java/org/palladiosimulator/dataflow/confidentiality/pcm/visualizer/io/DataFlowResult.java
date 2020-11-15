package org.palladiosimulator.dataflow.confidentiality.pcm.visualizer.io;

import java.util.List;

public class DataFlowResult implements DataFlowResultElement {

	private List<DataFlowGraph> dataFlowGraphs;
	private List<DataTypeUsage> dataTypeUsage;

	public List<DataFlowGraph> getDataFlowGraphs() {
		return dataFlowGraphs;
	}

	public void setDataFlowGraph(List<DataFlowGraph> dataFlowGraphs) {
		this.dataFlowGraphs = dataFlowGraphs;
	}

	public List<DataTypeUsage> getDataTypeUsage() {
		return dataTypeUsage;
	}

	public void setDataTypeUsage(List<DataTypeUsage> dataTypeUsage) {
		this.dataTypeUsage = dataTypeUsage;
	}

}

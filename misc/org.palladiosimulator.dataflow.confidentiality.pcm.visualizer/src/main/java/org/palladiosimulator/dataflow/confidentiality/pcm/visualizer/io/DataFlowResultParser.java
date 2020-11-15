package org.palladiosimulator.dataflow.confidentiality.pcm.visualizer.io;

import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.Reader;

import com.google.gson.Gson;

public class DataFlowResultParser {

	public DataFlowResult parse(File jsonFile) throws IOException {
		Gson gson = new Gson();
		try (Reader reader = new FileReader(jsonFile)) {
			DataFlowResult dataFlowResult = gson.fromJson(reader, DataFlowResult.class);
			return postProcess(dataFlowResult);
		}
	}

	protected DataFlowResult postProcess(DataFlowResult dataFlowResult) {
		dataFlowResult.getDataFlowGraphs().forEach(graph -> graph.setParent(dataFlowResult));
		dataFlowResult.getDataTypeUsage().forEach(dataTypeUsage -> dataTypeUsage.setParent(dataFlowResult));
		return dataFlowResult;
	}

}

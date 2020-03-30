package org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd;

import org.palladiosimulator.dataflow.diagram.DataFlowDiagram.DataFlowDiagram;
import org.palladiosimulator.pcm.usagemodel.UsageModel;

public interface PcmToDfdTransformation {

	public DataFlowDiagram transform(UsageModel usageModel);
	
}

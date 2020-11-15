package org.palladiosimulator.dataflow.confidentiality.pcm.visualizer.io;

import java.util.List;

public class DataFlowGraph extends ParentHaving<DataFlowResult> {

	private List<DataFlowNode> nodes;
	private List<DataFlowEdge> edges;

	public List<DataFlowNode> getNodes() {
		return nodes;
	}

	public void setNodes(List<DataFlowNode> nodes) {
		this.nodes = nodes;
	}

	public List<DataFlowEdge> getEdges() {
		return edges;
	}

	public void setEdges(List<DataFlowEdge> edges) {
		this.edges = edges;
	}

	@Override
	protected void setParentForChildren() {
		nodes.forEach(node -> node.setParent(this));
		edges.forEach(node -> node.setParent(this));
	}

	@Override
	public String toString() {
		return "DataFlowGraph [nodes=" + nodes.size() + ", edges=" + edges.size() + "]";
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = super.hashCode();
		result = prime * result + ((edges == null) ? 0 : edges.hashCode());
		result = prime * result + ((nodes == null) ? 0 : nodes.hashCode());
		return result;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (!super.equals(obj))
			return false;
		if (getClass() != obj.getClass())
			return false;
		DataFlowGraph other = (DataFlowGraph) obj;
		if (edges == null) {
			if (other.edges != null)
				return false;
		} else if (!edges.equals(other.edges))
			return false;
		if (nodes == null) {
			if (other.nodes != null)
				return false;
		} else if (!nodes.equals(other.nodes))
			return false;
		return true;
	}

}

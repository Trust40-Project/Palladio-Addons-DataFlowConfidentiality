package org.palladiosimulator.dataflow.confidentiality.pcm.visualizer.io;

import java.util.List;
import java.util.Optional;

public class DataTypeUsage extends ParentHaving<DataFlowResult> {

	private int dataFlowGraphId;
	private Entity entryLevelSystemCall;
	private List<Entity> readDataTypes;
	private List<Entity> writeDataTypes;

	public int getDataFlowGraphId() {
		return dataFlowGraphId;
	}

	public void setDataFlowGraphId(int dataFlowGraphId) {
		this.dataFlowGraphId = dataFlowGraphId;
	}

	public Entity getEntryLevelSystemCall() {
		return entryLevelSystemCall;
	}

	public void setEntryLevelSystemCall(Entity entryLevelSystemCall) {
		this.entryLevelSystemCall = entryLevelSystemCall;
	}

	public List<Entity> getReadDataTypes() {
		return readDataTypes;
	}

	public void setReadDataTypes(List<Entity> readDataTypes) {
		this.readDataTypes = readDataTypes;
	}

	public List<Entity> getWriteDataTypes() {
		return writeDataTypes;
	}

	public void setWriteDataTypes(List<Entity> writeDataTypes) {
		this.writeDataTypes = writeDataTypes;
	}

	public Optional<DataFlowGraph> getDataFlowGraph() {
		if (dataFlowGraphId < 0) {
			return Optional.empty();
		}
		return Optional.of(getParent().getDataFlowGraphs().get(dataFlowGraphId));
	}
	
	@Override
	protected void setParentForChildren() {
		// intentionally left blank
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + dataFlowGraphId;
		result = prime * result + ((entryLevelSystemCall == null) ? 0 : entryLevelSystemCall.hashCode());
		result = prime * result + ((readDataTypes == null) ? 0 : readDataTypes.hashCode());
		result = prime * result + ((writeDataTypes == null) ? 0 : writeDataTypes.hashCode());
		return result;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		DataTypeUsage other = (DataTypeUsage) obj;
		if (dataFlowGraphId != other.dataFlowGraphId)
			return false;
		if (entryLevelSystemCall == null) {
			if (other.entryLevelSystemCall != null)
				return false;
		} else if (!entryLevelSystemCall.equals(other.entryLevelSystemCall))
			return false;
		if (readDataTypes == null) {
			if (other.readDataTypes != null)
				return false;
		} else if (!readDataTypes.equals(other.readDataTypes))
			return false;
		if (writeDataTypes == null) {
			if (other.writeDataTypes != null)
				return false;
		} else if (!writeDataTypes.equals(other.writeDataTypes))
			return false;
		return true;
	}

}

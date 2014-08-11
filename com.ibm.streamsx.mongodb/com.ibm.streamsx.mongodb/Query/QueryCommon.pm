package QueryCommon;

use strict;
use warnings;

sub initBSONObject(@) {
	my ($attrName, $attrNameNotInBO, $cppType, $findPath) = @_;

print qq(
	for(;;)	{
		$cppType & attr0 = otuple.get_$attrName();
		bool valueApplied = false;
);

	if ($findPath) {

print qq(
	const BSONElement & be_$attrName = queryResultBO.getFieldDotted($findPath);
	if (be_$attrName.eoo()) break;
	const BSONObj & queryResultBO = be_$attrName.type() == Object ? be_$attrName.embeddedObject() : BSONObj();
);
	}
	
	if ($attrNameNotInBO) {
		if ($findPath) {

print qq(
		const BSONObj & bo0 = be_$attrName.wrap("$attrName");
);
		}
		else {

print qq(
		BSONObjBuilder b0;
		b0.append("$attrName", queryResultBO);
		const BSONObj & bo0 = b0.obj();
);
	}
		}
	else {
	
print qq(
		const BSONObj & bo0 = queryResultBO;
);
	}
}


sub endBSONObject {

print qq(
	break;
	}
);
}


sub handleBSONObject(@) {
	my ($exprLocation, $attrName, $splType, $seq) = @_;

	if ($attrName) {
	
print qq(
		cout << "BO: " << bo$seq.jsonString() << endl;
		if(bo$seq.hasElement("$attrName")) {
			const BSONElement & be$seq = bo$seq.getField("$attrName");
);

	}
	
	if(SPL::CodeGen::Type::isPrimitive($splType)) {
		QueryCommon::handlePrimitive($exprLocation, $splType, $seq);
	}

	elsif(SPL::CodeGen::Type::isList($splType) || SPL::CodeGen::Type::isBList($splType) ||
	   SPL::CodeGen::Type::isSet($splType) || SPL::CodeGen::Type::isBSet($splType)) {
		handleBSONArray($exprLocation, $splType, $seq);
	}
	
	elsif(SPL::CodeGen::Type::isMap($splType) || SPL::CodeGen::Type::isBMap($splType)) {
		handleBSONObjectAsMap($exprLocation, $splType, $seq);
	}
	
	elsif(SPL::CodeGen::Type::isTuple($splType)) {
		handleBSONObjectAsTuple($exprLocation, $splType, $seq);
	}
	
	else {
		SPL::CodeGen::errorln("Unsupported type %s.", $splType, $exprLocation);
	}
	
	if ($attrName) {

print qq(
	}
);
	}
}


sub handleBSONArray(@) {
	my ($exprLocation, $splType, $seq) = @_;
	my $valueType = SPL::CodeGen::Type::getElementType($splType);
	my $nextSeq = $seq+1;
	
print qq(
	if(be$seq.type() == Array) {
		typedef STREAMS_BOOST_TYPEOF((attr$seq)) cppExpr$seq; 
		// const std::vector<BSONElement> & listData$seq =  be$seq.Array();
		
		for (BSONObjIterator it$seq(be$seq.embeddedObject()); it$seq.more();) {
			cppExpr$seq\::value_type attr$nextSeq;
			const BSONElement & be$nextSeq = it$seq.next();
			bool valueApplied = false;
);

			handleBSONObject($exprLocation, '', $valueType, $nextSeq);

print qq(
			if(valueApplied) attr$seq.add(attr$nextSeq);
		}
		if(attr$seq.getSize() > 0) {
			valueApplied = true;
		}
	}
);

}


sub handleBSONObjectAsMap(@) {
	my ($exprLocation, $splType, $seq) = @_;
	my $keyType = SPL::CodeGen::Type::getKeyType($splType);
	my $valueType = SPL::CodeGen::Type::getValueType($splType);
	my $nextSeq = $seq+1;
	
	if(!SPL::CodeGen::Type::isString($keyType)) {
		SPL::CodeGen::errorln("The map key type %s must be of string type.", $keyType, $exprLocation);
	}

print qq(
	if(be$seq.type() == Object) {
		typedef STREAMS_BOOST_TYPEOF((attr$seq)) cppExpr$seq; 
		
		for (BSONObjIterator it$seq(be$seq.embeddedObject()); it$seq.more();) {
			cppExpr$seq\::mapped_type attr$nextSeq;
			const BSONElement & be$nextSeq = it$seq.next();
			bool valueApplied = false;
);

			handleBSONObject($exprLocation, '', $valueType, $nextSeq);

print qq(
			if(valueApplied) attr$seq.add(be$nextSeq.fieldName(), attr$nextSeq);
		}
		if(attr$seq.getSize() > 0) {
			valueApplied = true;
		}
	}
);

}


sub handleBSONObjectAsTuple(@) {
	my ($exprLocation, $splType, $seq) = @_;
	my @attrNames = SPL::CodeGen::Type::getAttributeNames($splType);
	my @attrTypes = SPL::CodeGen::Type::getAttributeTypes($splType);
	my $nextSeq = $seq+1;
	
print qq(
	if(be$seq.type() == Object) {
);

		for (my $i = 0; $i < @attrNames; $i++) {

print qq(
		{
			typedef STREAMS_BOOST_TYPEOF((attr$seq.get_$attrNames[$i]())) cppExpr$seq; 
			cppExpr$seq & attr$nextSeq = attr$seq.get_$attrNames[$i]();
			const BSONObj & bo$nextSeq = be$seq.embeddedObject();
);
			handleBSONObject($exprLocation, $attrNames[$i], $attrTypes[$i], $nextSeq);
			
print qq(
		}
);
		}
	
print qq(
		valueApplied = true;
	}
);
}


sub handleBSONObjectAsJson(@) {
	my ($attrName, $valueType) = @_;

	my $value = 'queryResultBO.jsonString()';
	if(SPL::CodeGen::Type::isUString($valueType)) {
		$value = "spl_cast<ustring,string>::cast($value)";
	}

print qq(
	otuple.set_$attrName($value);
);
}

	
sub handlePrimitive(@) {
	my ($exprLocation, $valueType, $seq) = @_;
	
print qq(
		// valueApplied = false;
		if(be$seq.isSimpleType()) {
			typedef STREAMS_BOOST_TYPEOF((attr$seq)) cppExpr$seq;
);
			if(SPL::CodeGen::Type::isComplex($valueType)) {
				SPL::CodeGen::errorln("The complex type is not supported.", $exprLocation);
			}
			elsif(SPL::CodeGen::Type::isBlob($valueType)) {
				handleBlob($seq);
			}
			elsif(SPL::CodeGen::Type::isBoolean($valueType)) {
				handleBoolean($seq);
			}
			elsif(SPL::CodeGen::Type::isEnum($valueType)) {
				handleEnum($seq, "cppExpr$seq");
			}
			elsif(SPL::CodeGen::Type::isDecimal($valueType)) {
				handleDecimal($seq, $valueType);
			}
			elsif(SPL::CodeGen::Type::isFloat($valueType)) {
				handleFloat($seq);
			}
			elsif(SPL::CodeGen::Type::isIntegral($valueType)) {
				handleInt($seq, $valueType);
			}
			elsif(SPL::CodeGen::Type::isRString($valueType)) {
				handleRString($seq);
			}
			elsif(SPL::CodeGen::Type::isUString($valueType)) {
				handleUString($seq);
			}
			elsif(SPL::CodeGen::Type::isTimestamp($valueType)) {
				handleTimestamp($seq);
			}
			elsif(SPL::CodeGen::Type::isXml($valueType)) {
				handleXml($seq);
			}

print qq(
		}
);
}


sub handleBlob($) {
my ($seq) = @_;

print qq(
	if(be$seq.type() == BinData) {
		int length;
		const char* blobData = be$seq.binDataClean(length);
		attr$seq = SPL::blob(blobData, length);
		valueApplied = true;
	}
);
}


sub handleBoolean {
my ($seq) = @_;

print qq(
	if(be$seq.isBoolean()) {
		attr$seq = be$seq.boolean();
		valueApplied = true;
	}
);
}


sub handleEnum {
my ($seq, $valueType) = @_;

print qq(
	if(be$seq.type() == String) {
		try {
			attr$seq = spl_cast<$valueType,string>::cast( be$seq.str());
			valueApplied = true;
	    }
	    catch (...) {}
	}
);
}


sub handleDecimal {
my ($seq, $valueType) = @_;

print qq(
	if(be$seq.isNumber()) {
		double value = be$seq.number();
		attr$seq = spl_cast<$valueType,double>::cast(value);
		valueApplied = true;
	}
);
}


sub handleFloat {
my ($seq) = @_;

print qq(
	if(be$seq.isNumber()) {
		attr$seq = be$seq.number();
		valueApplied = true;
	}
);
}


sub handleInt {
my ($seq, $valueType) = @_;

print qq(
	if(be$seq.type() == NumberDouble) {
		attr$seq = spl_cast<$valueType,double>::cast( be$seq.numberDouble());
		valueApplied = true;
	}
	else if(be$seq.type() == NumberInt) {
		attr$seq = be$seq.numberInt();
		valueApplied = true;
	}
	else if(be$seq.type() == NumberLong) {
		attr$seq = be$seq.numberLong();
		valueApplied = true;
	}
);
}


sub handleRString {
my ($seq) = @_;

print qq(
	if(be$seq.type() == String) {
		attr$seq = be$seq.str();
		valueApplied = true;
	}
);
}

sub handleUString {
my ($seq) = @_;

print qq(
	if(be$seq.type() == String) {
		attr$seq = spl_cast<ustring,string>::cast( be$seq.str());
		valueApplied = true;
	}
);
}


sub handleTimestamp {
my ($seq) = @_;

print qq(
	if(be$seq.type() == Date) {
		attr$seq = createTimestamp( be$seq.date().asInt64(), 0);
		valueApplied = true;
	}
	else if(be$seq.type() == Timestamp) {
		attr$seq = createTimestamp( be$seq.timestampTime().asInt64(), 0);
		valueApplied = true;
	}
);
}


sub handleXml {
my ($seq) = @_;

print qq(
	if(be$seq.type() == String) {
		attr$seq = spl_cast<xml,string>::cast( be$seq.str());
		valueApplied = true;
	}
);
}


sub keyLess($) {
	my ($splType) = @_;
	return not (SPL::CodeGen::Type::isBMap($splType) || SPL::CodeGen::Type::isMap($splType) || SPL::CodeGen::Type::isTuple($splType));
}

1;

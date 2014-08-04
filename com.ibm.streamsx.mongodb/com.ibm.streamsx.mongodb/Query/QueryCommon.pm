package QueryCommon;

use strict;
use warnings;

use File::Basename qw(dirname);

sub buildBSONObject(@) {
	my ($model, $exprLocation, $cppExpr, $splType, $seq) = @_;
	unshift @INC, dirname($model->getContext()->getOperatorDirectory()) . '/Common';
	require BSONCommon;
	BSONCommon::buildBSONObject($exprLocation, $cppExpr, $splType, $seq);
}

sub initBSONObject(@) {
	my ($attrName, $cppType) = @_;
	
print
<<"[----- c++ code -----]";
	{
		$cppType & attr0 = otuple.get_$attrName();
		const BSONObj & bo0 = queryResultBO;
		bool valueApplied = false;
[----- c++ code -----]
}


sub endBSONObject {
print
<<"[----- c++ code -----]";
	}
[----- c++ code -----]
}


sub handleBSONObject(@) {
	my ($exprLocation, $attrName, $splType, $seq) = @_;

	if ($attrName) {
print
<<"[----- c++ code -----]";
		cout << bo$seq.jsonString() << endl;
		if(bo$seq.hasElement(\"$attrName\")) {
			cout << "Field found" << endl;
			const BSONElement be$seq = bo$seq.getField(\"$attrName\");
[----- c++ code -----]
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
print
<<"[----- c++ code -----]";
	}
[----- c++ code -----]
	}
}


sub handleBSONArray(@) {
	my ($exprLocation, $splType, $seq) = @_;
	my $valueType = SPL::CodeGen::Type::getElementType($splType);
	my $nextSeq = $seq+1;
	
print
<<"[----- c++ code -----]";
	if(be$seq.type() == Array) {
		cout << "Field is array" << endl;
		cout << be$seq.toString(false) << endl;

		typedef STREAMS_BOOST_TYPEOF((attr$seq)) cppExpr$seq; 
		// const std::vector<BSONElement> & listData$seq =  be$seq.Array();
		
		for (BSONObjIterator it$seq(be$seq.embeddedObject()); it$seq.more();) {
			cppExpr$seq\::value_type attr$nextSeq;
			const BSONElement & be$nextSeq = it$seq.next();
			bool valueApplied = false;
		// foreach (const BSONElement & be$nextSeq, listData$seq) {
		//	bool valueApplied = true;
		//	cppExpr$seq\::value_type attr$nextSeq;
[----- c++ code -----]

			handleBSONObject($exprLocation, '', $valueType, $nextSeq);

print
<<"[----- c++ code -----]";
			if(valueApplied) attr$seq.add(attr$nextSeq);
			// attr$seq.add(attr$nextSeq);
			cout << "Field: " << attr$nextSeq << endl;
			cout << "List: " << attr$seq << endl;
		}
		if(attr$seq.getSize() > 0) {
			valueApplied = true;
		}
	}
[----- c++ code -----]
}


sub handleBSONObjectAsMap(@) {
	my ($exprLocation, $splType, $seq) = @_;
	my $keyType = SPL::CodeGen::Type::getKeyType($splType);
	my $valueType = SPL::CodeGen::Type::getValueType($splType);
	my $nextSeq = $seq+1;
	
	if(!SPL::CodeGen::Type::isString($keyType)) {
		SPL::CodeGen::errorln("The map key type %s must be of string type.", $keyType, $exprLocation);
	}

print
<<"[----- c++ code -----]";
	if(be$seq.type() == Object) {
		cout << "Field is object" << endl;
		cout << be$seq.toString(false) << endl;

		typedef STREAMS_BOOST_TYPEOF((attr$seq)) cppExpr$seq; 
		
		// foreach (const BSONElement & be$nextSeq, listData$seq) {
		for (BSONObjIterator it$seq(be$seq.embeddedObject()); it$seq.more();) {
			bool valueApplied = true;
			cppExpr$seq\::mapped_type attr$nextSeq;
			const BSONElement & be$nextSeq = it$seq.next();
			bool valueApplied = false;
[----- c++ code -----]

			handleBSONObject($exprLocation, '', $valueType, $nextSeq);

print
<<"[----- c++ code -----]";
			if(valueApplied) attr$seq.add(be$nextSeq.fieldName(), attr$nextSeq);
			// attr$seq.add(be$nextSeq.fieldName(), attr$nextSeq);
			cout << "Field: " << attr$nextSeq << endl;
			cout << "Map: " << attr$seq << endl;
		}
		if(attr$seq.getSize() > 0) {
			valueApplied = true;
		}
	}
[----- c++ code -----]
}


sub handleBSONObjectAsTuple(@) {
	my ($exprLocation, $splType, $seq) = @_;
	my @attrNames = SPL::CodeGen::Type::getAttributeNames($splType);
	my @attrTypes = SPL::CodeGen::Type::getAttributeTypes($splType);
	my $nextSeq = $seq+1;
	
print
<<"[----- c++ code -----]";
	if(be$seq.type() == Object) {
		cout << "Field is object" << endl;
		cout << be$seq.toString(false) << endl;
	
[----- c++ code -----]

		for (my $i = 0; $i < @attrNames; $i++) {

print
<<"[----- c++ code -----]";
		{
			typedef STREAMS_BOOST_TYPEOF((attr$seq.get_$attrNames[$i]())) cppExpr$seq; 
			cppExpr$seq & attr$nextSeq = attr$seq.get_$attrNames[$i]();
			const BSONObj & bo$nextSeq = be$seq.embeddedObject();
[----- c++ code -----]

			handleBSONObject($exprLocation, $attrNames[$i], $attrTypes[$i], $nextSeq);
			
print
<<"[----- c++ code -----]";
			cout << "Field $attrNames[$i]: " << attr$nextSeq << endl;
			cout << "Tuple: " << attr$seq << endl;
		}
[----- c++ code -----]
	
		}
	
print
<<"[----- c++ code -----]";
		valueApplied = true;
	}
[----- c++ code -----]
	
}


sub handlePrimitive(@) {
	my ($exprLocation, $valueType, $seq) = @_;
	
print
<<"[----- c++ code -----]";
		valueApplied = false;
		if(be$seq.isSimpleType()) {
			typedef STREAMS_BOOST_TYPEOF((attr$seq)) cppExpr$seq;
			cout << "Field is simple type" << endl;
			cout << be$seq.toString(false) << endl;
[----- c++ code -----]
			
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

print
<<"[----- c++ code -----]";
		}
[----- c++ code -----]
}


sub handleBlob {
print
<<"[----- c++ code -----]";
	if(be$_.type() == BinData) {
		int length;
		const char* blobData = be$_.binDataClean(length);
		attr$_ = SPL::blob(blobData, length);
		valueApplied = true;
	}
[----- c++ code -----]
}


sub handleBoolean {
print
<<"[----- c++ code -----]";
	if(be$_.isBoolean()) {
		attr$_ = be$_.boolean();
		valueApplied = true;
	}
[----- c++ code -----]
}


sub handleEnum {
my ($seq, $valueType) = @_;

print
<<"[----- c++ code -----]";
	if(be$seq.type() == String) {
		try {
			attr$seq = spl_cast<$valueType,string>::cast( be$seq.str());
			valueApplied = true;
	    }
	    catch (...) {}
	}
[----- c++ code -----]
}


sub handleDecimal {
my ($seq, $valueType) = @_;

print <<"[----- c++ code -----]";
	if(be$_.isNumber()) {
		double value = be$seq.number();
		attr$_ = spl_cast<$valueType,double>::cast(value);
		valueApplied = true;
	}
[----- c++ code -----]
}


sub handleFloat {
print
<<"[----- c++ code -----]";
	if(be$_.isNumber()) {
		attr$_ = be$_.number();
		valueApplied = true;
	}
[----- c++ code -----]
}


sub handleInt {
my ($seq, $valueType) = @_;

print
<<"[----- c++ code -----]";
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
[----- c++ code -----]
}


sub handleRString {
print
<<"[----- c++ code -----]";
	if(be$_.type() == String) {
		attr$_ = be$_.str();
		valueApplied = true;
	}
[----- c++ code -----]
}

sub handleUString {
print
<<"[----- c++ code -----]";
	if(be$_.type() == String) {
		attr$_ = spl_cast<ustring,string>::cast( be$_.str());
		valueApplied = true;
	}
[----- c++ code -----]
}


sub handleTimestamp {
print
<<"[----- c++ code -----]";
	if(be$_.type() == Date) {
		attr$_ = createTimestamp( be$_.date().asInt64(), 0);
		valueApplied = true;
	}
	else if(be$_.type() == Timestamp) {
		attr$_ = createTimestamp( be$_.timestampTime().asInt64(), 0);
		valueApplied = true;
	}
[----- c++ code -----]
}


sub handleXml {
print
<<"[----- c++ code -----]";
	if(be$_.type() == String) {
		attr$_ = spl_cast<xml,string>::cast( be$_.str());
		valueApplied = true;
	}
[----- c++ code -----]
}


sub keyLess($) {
	my ($splType) = @_;
	return not (SPL::CodeGen::Type::isBMap($splType) || SPL::CodeGen::Type::isMap($splType) || SPL::CodeGen::Type::isTuple($splType));
}

1;
